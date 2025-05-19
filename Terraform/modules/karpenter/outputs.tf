output "node_iam_role_name" {
  description = "IAM Role name for Karpenter nodes"
  value       = module.karpenter.node_iam_role_name
}

output "service_account" {
  description = "Karpenter service account name"
  value       = module.karpenter.service_account
}

output "queue_name" {
  description = "Karpenter interruption queue name"
  value       = module.karpenter.queue_name
}
