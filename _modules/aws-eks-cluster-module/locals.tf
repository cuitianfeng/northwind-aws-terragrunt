locals {
  aws_load_balancer_controller_policy_name = "AWSLoadBalancerControllerIAMPolicy"
  aws_load_balancer_controller_policy_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.aws_load_balancer_controller_policy_name}"
  aws_load_balancer_controller_role_name   = "${local.values.env}-${local.values.project}-aws-load-balancer-controller-role"
  aws_cluster_autoscaler_policy_name = "${local.values.aws_cluster_autoscaler_policy_name}"
  aws_cluster_autoscaler_policy_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.aws_cluster_autoscaler_policy_name}"
  aws_cluster_autoscaler_role_name   = "${local.values.env}-${local.values.project}-aws-cluster-autoscaler-role"
  aws_eks_efs_csi_driver_policy_name = "AWSEksEfsCsiDriverIAMPolicy"
  aws_eks_efs_csi_driver_policy_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.aws_eks_efs_csi_driver_policy_name}"
  aws_eks_efs_csi_driver_role_name   = "${local.values.env}-${local.values.project}-eks-efs-csi-driver-role"
  aws_eks_autoscaler_policy_json_default_name = "${local.values.aws_eks_autoscaler_policy_json_default_name}"
}
