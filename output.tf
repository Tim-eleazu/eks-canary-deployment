output "eks_node_group_status" {
  value = aws_eks_node_group.eks-node-group.status
}

output "ec2_instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.runner_server.public_ip
}