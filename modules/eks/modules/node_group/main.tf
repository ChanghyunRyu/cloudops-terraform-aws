###############################################
####               IAM Role                ####
###############################################

resource "aws_iam_role" "this" {
  name = "${var.name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.default_tags
}

resource "aws_iam_role_policy_attachment" "node_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

###############################################
####              Node Group               ####
###############################################

resource "aws_eks_node_group" "this" {
    cluster_name = var.cluster_name
    node_group_name = "${var.name}-node-group"
    node_role_arn = aws_iam_role.this.arn
    subnet_ids = var.private_subnet_ids

    instance_types = var.instance_types
    disk_size = var.disk_size

    scaling_config {
        desired_size = var.desired_size
        max_size = var.max_size
        min_size = var.min_size
    }

    ami_type = "AL2_x86_64"
    capacity_type = "ON_DEMAND"
    force_update_version = true

    tags = var.default_tags

    depends_on = [aws_iam_role_policy_attachment.node_policy_attachment]
}