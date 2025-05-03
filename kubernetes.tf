#Configures the Kubernetes provider to connect securely to your EKS cluster using its API endpoint, certificate, and authentication token.
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
}

# #Deploys the Kubernetes objects defined in the 2048_full.yaml file by decoding the YAML and applying it to the cluster.
# resource "kubernetes_manifest" "game_2048" {
#   manifest = yamldecode(file("${path.module}/2048_full.yaml"))
#   depends_on             = [
#     aws_eks_cluster.eks,
#     aws_eks_addon.eks_coredns,
#     aws_eks_addon.eks_kubeproxy,
#     aws_eks_addon.eks_vpc_cni
#   ]
# }


resource "kubernetes_namespace" "game_2048" {
  metadata {
    name = var.namespace
  }
}


resource "kubernetes_deployment" "game_2048" {
  metadata {
    name = "deployment-2048"
    namespace = var.namespace

  }

  spec {
    replicas = 5

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "app-2048"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "app-2048"
        }
      }

      spec {
        container {
          image = "public.ecr.aws/l6m2t8p7/docker-2048:latest"
          name  = "app-2048"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }

        }
      }
    }
    
  }
  depends_on = [
  aws_eks_cluster.eks,
  aws_eks_addon.eks_coredns,
  aws_eks_addon.eks_kubeproxy,
  aws_eks_addon.eks_vpc_cni
]

}


#Service
resource "kubernetes_service" "game_2048" {
  metadata {
    name = "service-2048"
    namespace = var.namespace
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = "app-2048"
    }
    port {
      port        = 80
      target_port = 80
      protocol = "TCP"
    }

    type = "NodePort"
  }
  depends_on = [
  aws_eks_cluster.eks,
  aws_eks_addon.eks_coredns,
  aws_eks_addon.eks_kubeproxy,
  aws_eks_addon.eks_vpc_cni
]
}


resource "kubernetes_ingress_v1" "game_2048" {
  metadata {
    name = "ingress-2048"
    namespace = var.namespace
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "kubernetes.io/ingress.class" = "alb"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "service-2048"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
  aws_eks_cluster.eks,
  aws_eks_addon.eks_coredns,
  aws_eks_addon.eks_kubeproxy,
  aws_eks_addon.eks_vpc_cni
]

}