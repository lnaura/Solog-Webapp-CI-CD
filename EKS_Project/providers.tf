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