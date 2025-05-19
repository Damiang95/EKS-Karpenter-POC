output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "node_iam_role_name" {
  description = "IAM Role name for Karpenter nodes"
  value       = module.karpenter.node_iam_role_name
}
