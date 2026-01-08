# 1. VPC 구성 (네트워크)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0" # 최신 안정 버전 사용

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"] # 워커 노드가 배치될 곳 (보안)
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"] # 로드밸런서가 배치될 곳

  enable_nat_gateway = true # Private Subnet의 노드가 인터넷(ECR 등)에 접근하기 위해 필수
  single_nat_gateway = true # 비용 절감을 위해 1개만 생성 (운영 환경에선 false 권장)
  enable_dns_hostnames = true

  # EKS가 로드밸런서를 생성할 때 필요한 태그
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# 2. EKS 클러스터 구성
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.2.0"

  cluster_name    = "gitops-cluster"
  cluster_version = "1.29" # 안정적인 K8s 버전 선택

  cluster_endpoint_public_access = true # 로컬 PC에서 kubectl로 접속 허용

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # 워커 노드는 반드시 Private에 배치

  # OIDC 자격 증명 공급자 활성화 (나중에 IRSA 사용 시 필수)
  enable_irsa = true

  # 관리형 노드 그룹 (실제 서버)
  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"] # Spring Boot + React + ArgoCD 돌리려면 t3.small은 부족할 수 있음
      capacity_type  = "ON_DEMAND"
    }
  }

  # 현재 Terraform을 돌리는 사용자에게 클러스터 관리자 권한 부여
  enable_cluster_creator_admin_permissions = true
}

# 3. ECR 리포지토리 (Backend: Spring Boot)
resource "aws_ecr_repository" "backend" {
  name                 = "solog-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 4. ECR 리포지토리 (Frontend: React)
resource "aws_ecr_repository" "frontend" {
  name                 = "solog-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# AWS Load Balancer Controller를 위한 IAM Role 생성(IRSA)

module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~>5.30"
  role_name = "solog-eks-lb-controller-role"

  # OIDC Provider와 연결 (이게 되어야 K8s가 AWS IAM을 빌려 씁니다)
  # module.eks.oidc_provider_arn 등 기존 EKS 모듈의 output을 참조하세요.
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  attach_load_balancer_controller_policy = true
}

# 2. Helm Chart를 이용해 컨트롤러 설치
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  # 설치 시 값을 동적으로 주입 (ServiceAccount에 IAM Role 연결)
  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  # 핵심: 위에서 만든 IAM Role의 ARN을 주석(Annotation)으로 달아줍니다.
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_role.iam_role_arn
  }
}