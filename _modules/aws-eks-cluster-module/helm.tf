locals {
  eks_init_helm_releases = {
  true = {}
  false = {
    aws-node-termination-handler = {
        name       = "aws-node-termination-handler"
        chart      = "aws-node-termination-handler"
        version    = "0.16.0"
        repository = "https://aws.github.io/eks-charts"
        namespace  = "kube-system"
        values     = {
            enableSpotInterruptionDraining = true
        }
    }
    // kube-state-metrics = {
    //     name       = "kube-state-metrics"
    //     namespace  = "kube-system"
    //     chart      = "kube-state-metrics"
    //     version    = "4.3.0"
    //     repository = "https://prometheus-community.github.io/helm-charts"
    //     values     = {}
    // }
    metrics-server = {
        name       = "metrics-server"
        namespace  = "kube-system"
        chart      = "metrics-server"
        version    = "3.7.0"
        repository = "https://kubernetes-sigs.github.io/metrics-server/"
        values     = {}
    }
    // prometheus-node-exporter = {
    //     name       = "prometheus-node-exporter"
    //     namespace  = "kube-system"
    //     chart      = "prometheus-node-exporter"
    //     version    = "2.4.1"
    //     repository = "https://prometheus-community.github.io/helm-charts"
    //     values     = {
    //       resources = {
    //         limits = {
    //           cpu: "200m"
    //           memory: "100Mi"
    //         }
    //         requests = {
    //           cpu: "100m"
    //           memory: "100Mi"
    //         }
    //       }
    //     }
    // }
    aws-load-balancer-controller = {
        name       = "aws-load-balancer-controller"
        chart      = "aws-load-balancer-controller"
        version    = "1.3.3"
        repository = "https://aws.github.io/eks-charts"
        namespace  = "kube-system"
        values     = {
            clusterName    = module.eks.cluster_id
            serviceAccount = {
              annotations  = {
                "eks.amazonaws.com/role-arn" = format("arn:aws:iam::%s:role/%s",
                  data.aws_caller_identity.current.account_id,
                  local.aws_load_balancer_controller_role_name
                )
              }
            }
        }
    }
    aws-cluster-autoscaler = {
        name       = "aws-cluster-autoscaler"
        chart      = "cluster-autoscaler"
        version    = "9.16.0"
        repository = "https://kubernetes.github.io/autoscaler"
        namespace  = "kube-system"
        values     = {
            autoDiscovery = {
              clusterName = module.eks.cluster_id
            }
            awsRegion = data.aws_region.current.name
            podAnnotations = {
              "cluster-autoscaler.kubernetes.io/enable-ds-eviction" = "false"
            }
            rbac = {
              serviceAccount = {
                annotations  = {
                  "eks.amazonaws.com/role-arn" = format("arn:aws:iam::%s:role/%s",
                    data.aws_caller_identity.current.account_id,
                    local.aws_cluster_autoscaler_role_name
                  )
                }
              }
            }
        }
    }

  }
  }
}




provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    exec {
      api_version = local.values.helm_api_version
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
      command     = "aws"
    }
  }
}


resource "helm_release" "init" {
  for_each          = local.eks_init_helm_releases[local.values.disable_helm_resource]
  name              = each.key
  repository        = each.value.repository
  chart             = each.value.chart
  version           = each.value.version
  namespace         = each.value.namespace
  create_namespace  = lookup(each.value, "create_namespace", false)

  values = [
      yamlencode(each.value.values)
  ]
}

resource "helm_release" "custom" {
  for_each          = local.values.custom_helm_releases
  name              = each.key
  repository        = each.value.repository
  chart             = each.value.chart
  version           = each.value.version
  namespace         = each.value.namespace
  create_namespace  = lookup(each.value, "create_namespace", false)

  values = [
      each.value.values
  ]

  depends_on = [
    helm_release.init,
  ]
}
