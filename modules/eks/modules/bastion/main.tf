###############################################
####               IAM Role                ####
###############################################

resource "aws_iam_role" "this" {
    name = "${var.name}-bastion-role"

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

resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_policy" "baston_describe_cluster_policy" {
  name        = "eks-describe-cluster-policy"
  description = "Policy to allow eks:DescribeCluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "describe_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.baston_describe_cluster_policy.arn
}

resource "aws_iam_instance_profile" "this" {
    name = "${var.name}-bastion-profile"
    role = aws_iam_role.this.name
}

###############################################
####            Security Group             ####
###############################################

resource "aws_security_group" "this" {
  name        = "${var.name}-bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 필요 시 제한
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
####             Bastion Host              ####
###############################################

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh.tpl")

  vars = {
    cluster_name = var.cluster_name
    region = var.region
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data                   = data.template_file.user_data.rendered

  tags = merge(var.default_tags, {
    Name = "${var.name}-bastion"
  })
}