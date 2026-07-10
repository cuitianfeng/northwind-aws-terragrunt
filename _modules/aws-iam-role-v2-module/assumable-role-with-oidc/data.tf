data "aws_eks_cluster" "eks" {
  name = "${local.values.env}-${local.values.project}-eks"
}