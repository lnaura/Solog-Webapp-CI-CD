output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = "ap-northeast-2"
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "configure_kubectl" {
  description = "Configure kubectl: run this command"
  value       = "aws eks update-kubeconfig --region ap-northeast-2 --name ${module.eks.cluster_name}"
}

output "ecr_repository_urls" {
  description = "ECR Repository URLs"
  value = {
    backend  = aws_ecr_repository.backend.repository_url
    frontend = aws_ecr_repository.frontend.repository_url
  }
}