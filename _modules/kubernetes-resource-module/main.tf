terraform {
  experiments = [module_variable_optional_attrs]
} 

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  experiments {
      manifest_resource = true
  }
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "helm_release" "custom" {
  for_each          = local.values.custom_helm_releases
  name              = split("_", each.key)[1]
  namespace         = split("_", each.key)[0]
  repository        = each.value.repository
  chart             = each.value.chart
  version           = each.value.version
  create_namespace  = true

  values = [
      each.value.values
  ]
}

resource "kubernetes_manifest" "custom" {
  depends_on = [
    helm_release.custom
  ]
  for_each = local.values.custom_kubernetes_manifests
  manifest = yamldecode(each.value)
}