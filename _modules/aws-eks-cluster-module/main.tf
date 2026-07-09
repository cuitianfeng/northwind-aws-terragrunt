terraform {
  experiments = [module_variable_optional_attrs]
} 

provider "kubernetes" {
  experiments {
      manifest_resource = true
  }
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "aws_iam_openid_connect_provider" "default" {
  url             = module.eks.cluster_oidc_issuer_url
  client_id_list  = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  tags = merge(
    {
      Terraform = "true"
      Project     = local.values.project
      Owners      = local.values.owners
      Env         = local.values.env
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )    
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_version = local.values.cluster_version
  cluster_name    = "${local.values.env}-${local.values.project}-eks"
  vpc_id          = data.aws_vpc.selected_vpc.id
  subnets         = [for subnet in data.aws_subnet.selected_private_subnet: subnet.id]

  cluster_endpoint_public_access        = local.values.cluster_endpoint_public_access
  cluster_endpoint_private_access       = true
  cluster_create_endpoint_private_access_sg_rule = true
  cluster_endpoint_private_access_sg    = local.values.cluster_endpoint_private_access_sg
  cluster_endpoint_private_access_cidrs = local.values.cluster_endpoint_private_access_cidrs

  node_groups_defaults = {
    ami_type      = "AL2_x86_64"
    disk_size     = 100
    iam_role_additional_policies          = concat(
      ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"],
      local.values.iam_role_additional_policies
    )
  }

  node_groups     = yamldecode(local.values.node_groups)

  map_roles       = yamldecode(local.values.map_roles)
  map_users       = yamldecode(local.values.map_users)


  tags = merge(
    {  Name        = format("%s-%s-eks", local.values.env, local.values.project)
       Terraform   = "true"
       Project     = local.values.project
       Moniker     = local.values.project
       Owners      = local.values.owners
       Env         = local.values.env
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )
}