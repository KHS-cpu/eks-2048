variable "cluster_name" {
  description = "This is cluster name"
  type = string
  default = "eks-game"
}

variable "region" {
  description = "This is the region"
  type = string
  default = "ap-southeast-1"
}

variable "namespace" {
  description = "This is the namespace to use"
  type = string
  default = "game-2048"
}

variable "eks_policies" {
  description = "This is the policies to attach eks role"
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  ]
}