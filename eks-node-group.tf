resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.eksnode-group-name
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = [aws_subnet.subnet-name.id, aws_subnet.public-subnet2.id]


  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  ami_type       = var.eks_node_group_ami
  instance_types = [var.instance_type]
  disk_size      = 20

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}