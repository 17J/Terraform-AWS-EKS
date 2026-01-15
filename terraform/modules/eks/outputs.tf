output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}

output "node_group_id" {
  value = aws_eks_node_group.node_group.id
}