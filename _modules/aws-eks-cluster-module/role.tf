resource "null_resource" "create_iam_if_not_exist" {
  provisioner "local-exec" {
    command = "aws iam get-policy --policy-arn ${local.aws_load_balancer_controller_policy_arn} > /dev/null || aws iam create-policy --policy-name ${local.aws_load_balancer_controller_policy_name} --policy-document file://${path.module}/aws-load-balancer-controller-iam-policy.json"
  }
}

module "aws_load_balancer_controller_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = local.aws_load_balancer_controller_role_name
  role_policy_arns              = [local.aws_load_balancer_controller_policy_arn]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
  tags = {
    Terraform = "true"
    Project   = local.values.project
    Owners    = local.values.owners
    Env       = local.values.env
  }
  depends_on = [
    aws_iam_openid_connect_provider.default,
    null_resource.create_iam_if_not_exist
  ]
}

resource "null_resource" "create_cluster_autoscaler_iam_policy_if_not_exist" {
  provisioner "local-exec" {
    command = "aws iam get-policy --policy-arn ${local.aws_cluster_autoscaler_policy_arn} > /dev/null || aws iam create-policy --policy-name ${local.aws_cluster_autoscaler_policy_name} --policy-document file://${path.module}/${local.aws_eks_autoscaler_policy_json_default_name}"
  }
}

module "aws_cluster_autoscaler_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = local.aws_cluster_autoscaler_role_name
  role_policy_arns              = [local.aws_cluster_autoscaler_policy_arn]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-cluster-autoscaler"]
  tags = {
    Terraform = "true"
    Project   = local.values.project
    Owners    = local.values.owners
    Env       = local.values.env
  }
  depends_on = [
    aws_iam_openid_connect_provider.default,
    null_resource.create_cluster_autoscaler_iam_policy_if_not_exist
  ]
}

resource "null_resource" "create_eks_efs_csi_driver_iam_policy_if_not_exist" {
  provisioner "local-exec" {
    command = "aws iam get-policy --policy-arn ${local.aws_eks_efs_csi_driver_policy_arn} > /dev/null || aws iam create-policy --policy-name ${local.aws_eks_efs_csi_driver_policy_name} --policy-document file://${path.module}/aws-eks-efs-csi-driver-iam-policy.json"
  }
}

module "aws_eks_efs_csi_driver_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = local.aws_eks_efs_csi_driver_role_name
  role_policy_arns              = [local.aws_eks_efs_csi_driver_policy_arn]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
  tags = {
    Terraform = "true"
    Project   = local.values.project
    Owners    = local.values.owners
    Env       = local.values.env
  }
  depends_on = [
    aws_iam_openid_connect_provider.default,
    null_resource.create_eks_efs_csi_driver_iam_policy_if_not_exist
  ]
}