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

# 2. Kubernetes 프로바이더 설정
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# 3. Helm 프로바이더
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}