data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks.name
}

data "tls_certificate" "eks_oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}