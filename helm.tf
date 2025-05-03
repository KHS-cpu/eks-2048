provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_auth.token
  }
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = "ap-southeast-1"
  }

  set {
    name  = "vpcId"
    value = aws_vpc.eks_vpc.id
  }

  set {
    name  = "tolerations[0].key"
    value = "eks.amazonaws.com/compute-type"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }

  set {
    name  = "tolerations[0].value"
    value = "fargate"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  depends_on = [ 
    aws_iam_role.alb_controller,
    kubernetes_service_account.alb_controller,
    kubernetes_ingress_v1.game_2048
   ]
}