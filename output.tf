output "eks_node_group_status" {
  value = aws_eks_node_group.eks-node-group.status
}