resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.EKSClusterRole.arn
  vpc_config {
    subnet_ids         = [aws_subnet.subnet-name.id, aws_subnet.public-subnet2.id]
    security_group_ids = [aws_security_group.security-group-name.id]
  }

  version = 1.28

  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]

  provisioner "local-exec" {
    command = <<EOT
      aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.eks-cluster.name}
      kubectl apply -f deployment.yaml
      kubectl apply -f service.yaml
    EOT
  }
}