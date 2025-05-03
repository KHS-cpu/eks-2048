#Create IAM policy for AWS Load Balancer Controller
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam_policy.json")
}

#Create IAM role for AWS Load Balancer Controller
resource "aws_iam_role" "alb_controller" {
  name = "AmazonEKSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks_oidc.arn    #This role trusts tokens from your EKS cluster's OIDC provider
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
  depends_on = [ 
    aws_iam_openid_connect_provider.eks_oidc
   ]
}

#Attach the role created and policy
resource "aws_iam_role_policy_attachment" "alb_policy_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
  depends_on = [ 
    aws_iam_policy.aws_lb_controller_policy,
    aws_iam_role.alb_controller
   ]
}

#Binds the kubernetes service account and role created for alb controller
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
  depends_on = [ 
    aws_iam_role_policy_attachment.alb_policy_attach,
    aws_eks_cluster.eks,
    aws_eks_addon.eks_coredns,
    aws_eks_addon.eks_kubeproxy,
    aws_eks_addon.eks_vpc_cni
   ]
}

# #Temp
# # Create IAM Role for Node Group
# resource "aws_iam_role" "eks_node" {
#   name = "eks-node-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# # Attach the necessary policies to the node role
# resource "aws_iam_role_policy_attachment" "eks_node_policies" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

# resource "aws_iam_role_policy_attachment" "ec2_container_registry_policy" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# resource "aws_iam_role_policy_attachment" "vpc_resource_controller_policy" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonVPCResourceController"
# }

# resource "aws_iam_role_policy_attachment" "aws_lb_controller_policy" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
# }

# resource "aws_eks_node_group" "alb_controller_ng" {
#   cluster_name    = var.cluster_name
#   node_group_name = "alb-controller-ng"
#   node_role_arn   = aws_iam_role.eks_node.arn
#   subnet_ids      = [
#     aws_subnet.private_subnet_a.id,
#     aws_subnet.private_subnet_b.id
#   ]

#   instance_types = ["t3.small"]

#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 1
#   }

#   labels = {
#     "run" = "alb-controller"
#   }

#   tags = {
#     "Name"                              = "alb-controller-ng"
#     "k8s.io/cluster-autoscaler/enabled" = "true"
#   }
# }
