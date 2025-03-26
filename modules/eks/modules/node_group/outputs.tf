output "node_group_name" {
    description = "Name of the EKS Node Group"
    value = aws_eks_node_group.this.node_group_name
}