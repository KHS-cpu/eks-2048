resource "aws_eks_fargate_profile" "fp" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "2048-game"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
  subnet_ids             = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  

  selector {
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }

  selector {
    namespace = "kube-system"
    labels = {
      k8s-app = "kube-dns"
    }
  }
    selector {
    namespace = "default"
  }
  selector {
    namespace = var.namespace
    }
}