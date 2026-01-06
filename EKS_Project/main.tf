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