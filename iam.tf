resource "aws_iam_role" "eks" {
  name = "eks_cluster_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.cluster_name}_eks_role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attach" {
  for_each   = toset(var.eks_policies)
  role      = aws_iam_role.eks.name
  policy_arn = each.value
}


resource "aws_iam_role" "fargate_pod_execution" {
  name = "fargate_pod_execution_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.cluster_name}_fargate_pod_role"
  }
}


resource "aws_iam_role_policy_attachment" "fargate_pod_role_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution.name
}


resource "aws_iam_role" "node_iam" {
  name = "node_iam_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.cluster_name}_fargate_pod_role"
  }
}