data "aws_eks_cluster" "eks" {
  name = local.values.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = local.values.cluster_id
}