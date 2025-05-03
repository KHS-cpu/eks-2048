output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "subnet_ids" {
  value = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id,
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
}

output "internet_gw" {
  value = aws_internet_gateway.eks_igw.id
}

output "nat_gw" {
  value = aws_nat_gateway.eks_nat_gw.id
}

output "cluster_arn" {
  value = aws_eks_cluster.eks.arn
}
