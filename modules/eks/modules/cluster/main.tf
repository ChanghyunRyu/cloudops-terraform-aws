###############################################
####               IAM Role                ####
###############################################

resource "aws_iam_role" "this" {
    name = "${var.name}-eks-cluster-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "eks.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }]
    })

    tags = var.default_tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy_attachment"{
    for_each = toset([
        "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
        "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    ])
    role = aws_iam_role.this.name
    policy_arn = each.value
}

###############################################
####            Security Group             ####
###############################################

resource "aws_security_group" "this" {
  name        = "${var.name}-eks-cluster-sg"
  description = "EKS Cluster security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}

###############################################
####              EKS Cluster              ####
###############################################

resource "aws_eks_cluster" "this" {
    name = "${var.name}-cluster"
    version = var.kubernetes_version
    role_arn = aws_iam_role.this.arn
    enabled_cluster_log_types = var.cluster_enabled_log_types

    vpc_config {
        security_group_ids = [aws_security_group.this.id]
        subnet_ids = var.private_subnet_ids
        endpoint_private_access = true
        endpoint_public_access = false
    }

    access_config {
        authentication_mode = "API_AND_CONFIG_MAP"
        bootstrap_cluster_creator_admin_permissions = true
    }

    tags = var.default_tags
}

data "aws_eks_cluster_auth" "this" {
    name = aws_eks_cluster.this.name
}