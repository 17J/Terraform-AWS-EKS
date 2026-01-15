output "cluster_id" {
  value = module.eks.cluster_id
}

output "node_group_id" {
  value = module.eks.node_group_id
}
output "vpc_id" {
  value = module.vpc.vpc_id
}