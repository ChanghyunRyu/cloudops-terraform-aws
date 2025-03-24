output "node_group_name" {
    description = "Name of the EKS Node Group"
    value = aws_eks_node_group.this.node_group_name
}

output "node_group_iam_role_arn" {
    description = "IAM Role ARN for the Node Group"
    value = aws_iam_role.this.arn
}