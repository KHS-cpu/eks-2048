#Create EKS Cluster
resource "aws_eks_cluster" "eks" {
  name = var.cluster_name

  role_arn = aws_iam_role.eks.arn
  version  = "1.32"

  vpc_config {
    
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    
    subnet_ids = [
      aws_subnet.private_subnet_a.id,
      aws_subnet.private_subnet_b.id
    ]
   
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
  aws_iam_role_policy_attachment.eks_cluster_role_attach["arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"],
  aws_iam_role_policy_attachment.eks_cluster_role_attach["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"],
  aws_iam_role_policy_attachment.eks_cluster_role_attach["arn:aws:iam::aws:policy/AmazonEKSComputePolicy"],
  aws_iam_role_policy_attachment.eks_cluster_role_attach["arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"],
  aws_iam_role_policy_attachment.eks_cluster_role_attach["arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"]
]
}

#Create coredns pod
resource "aws_eks_addon" "eks_coredns" {
  cluster_name = aws_eks_cluster.eks.id
  addon_name   = "coredns"
  addon_version  = "v1.11.4-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [ aws_eks_fargate_profile.fp ]
}

#Create kubeproxy pod
resource "aws_eks_addon" "eks_kubeproxy" {
  cluster_name = aws_eks_cluster.eks.id
  addon_name   = "kube-proxy"
  addon_version  = "v1.32.0-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [ aws_eks_fargate_profile.fp ]
}

#Create coredns pod
resource "aws_eks_addon" "eks_vpc_cni" {
  cluster_name = aws_eks_cluster.eks.id
  addon_name   = "vpc-cni"
  addon_version  = "v1.19.2-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [ aws_eks_fargate_profile.fp ]
}


#Creates an IAM OIDC identity provider using your EKS cluster’s OIDC issuer, enabling Kubernetes service accounts to securely assume IAM roles via web identity (IRSA)
#Without this OIDC provider: You cannot create IAM roles that Kubernetes pods can assume via service accounts.
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer

  client_id_list = [      #This specifies who is allowed to assume roles via OIDC.
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]
  depends_on = [aws_eks_cluster.eks]
}