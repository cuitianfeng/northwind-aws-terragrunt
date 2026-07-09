data "aws_eks_cluster" "eks" {
  name = local.values.eks_cluster_id
}