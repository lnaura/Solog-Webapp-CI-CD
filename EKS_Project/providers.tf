#AWS 리전, 프로바이더 설정
provider "aws" {
  region = "ap-northeast-2"
  
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "gitops-project"
      ManagedBy   = "Terraform"
    }
  }
}

# EKS 클러스터 정보 가져오기 (data source)
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name # 본인의 EKS 모듈 이름에 맞게 수정
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# 2. Kubernetes 프로바이더 설정
# Terraform이 쿠버네티스 API 서버에 명령을 내릴 수 있게 해줍니다.
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}

# 3. Helm 프로바이더 설정
# Terraform이 'helm install' 명령어를 수행할 수 있게 해줍니다.
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}