// resource "kubernetes_namespace" "app" {
//   depends_on = [
//     module.eks
//   ]
//   metadata {
//     name = "app"
//   }
// }
// resource "kubernetes_priority_class_v1" "high" {
//   depends_on = [
//     module.eks
//   ]
//   metadata {
//     name = "high"
//   }
//   value = 300
// }
// resource "kubernetes_priority_class" "medium" {
//   depends_on = [
//     module.eks
//   ]
//   metadata {
//     name = "medium"
//   }
//   value = 200
// }
// resource "kubernetes_priority_class" "low" {
//   depends_on = [
//     module.eks
//   ]
//   metadata {
//     name = "low"
//   }
//   value = 100
// }

// resource "kubernetes_stateful_set" "debugger" {
//   depends_on = [
//     module.eks
//   ]
//   metadata {
//     name = "debugger"
//   }
//   spec {
//     service_name = "debugger"
//     selector {
//       match_labels = {
//         k8s-app = "debugger"
//       }
//     }
//     template {
//       metadata {
//         labels = {
//           k8s-app = "debugger"
//         }
//         annotations = {}
//       }
//       spec {
//         termination_grace_period_seconds = 5
//         container {
//           image   = "nicolaka/netshoot:v0.1"
//           name    = "debugger"
//           command = ["sleep", "infinity"]
//           resources {
//             limits = {
//               cpu    = "100m"
//               memory = "50Mi"
//             }
//             requests = {
//               cpu    = "10m"
//               memory = "50Mi"
//             }
//           }
//         }
//       }
//     }
//   }
// }

// resource "kubernetes_cluster_role" "cluster_readonly" {
//   depends_on = [
//     module.eks
//   ]
//   metadata {
//     name = "cluster-readonly-clusterrole"
//     labels = {
//       Terraform = "true"
//     }
//   }
//   rule {
//     api_groups = [""]
//     resources  = ["pods","configmaps","services","events","namespaces","nodes","limitranges","persistentvolumes","persistenttvolumeclaims","resourcequotas"]
//     verbs      = ["get", "list", "watch"]
//   }
//   rule {
//     api_groups = ["app"]
//     resources  = ["*"]
//     verbs      = ["get", "list", "watch"]
//   }
// }

// resource "kubernetes_cluster_role_binding_v1" "cluster_readonly" {
//   depends_on = [
//     module.eks
//   ]
//   metadata {
//     name = "cluster-readonly"
//     labels = {
//       Terraform = "true"
//     }
//   }
//   role_ref {
//     api_group = "rbac.authorization.k8s.io"
//     kind      = "ClusterRole"
//     name      = "cluster-readonly-clusterrole"
//   }
//   subject {
//     kind      = "Group"
//     name      = "cluster-readonly"
//     api_group = "rbac.authorization.k8s.io"
//   }
// }

# resource "kubernetes_manifest" "ingress" {
#   for_each   = toset(["internal", "internet-facing"])
#   depends_on = [
#     module.eks,
#     helm_release.init
#   ]
#   manifest   = {
#     apiVersion = "networking.k8s.io/v1"
#     kind       = "Ingress"
#     metadata   = {
#       name        = format("traefik-alb-%s", each.key)
#       namespace   = "kube-system"
#       annotations = {
#         "kubernetes.io/ingress.class"                = "alb"
#         "alb.ingress.kubernetes.io/target-type"      = "ip"
#         "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
#         "alb.ingress.kubernetes.io/certificate-arn"  = local.values.acm_certificate_arn
#         "alb.ingress.kubernetes.io/subnets"          = each.key == "internal" ? join(",", [for subnet in data.aws_subnet.selected_private_subnet: subnet.id]) : join(",", [for subnet in data.aws_subnet.selected_public_subnet: subnet.id])
#         "alb.ingress.kubernetes.io/scheme"           = each.key
#         "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([{HTTP: 80, HTTPS: 443}])
#         "alb.ingress.kubernetes.io/healthcheck-port" = "9000"
#         "alb.ingress.kubernetes.io/healthcheck-path" = "/ping"
#         "alb.ingress.kubernetes.io/conditions.traefik" = each.key == "internal" ? "[]" : jsonencode([
#             {
#               field            = "http-header",
#               httpHeaderConfig = {
#                 httpHeaderName = "x-cdn-key",
#                 values         = ["M2VhZGJkYWI5", "ZWQ3ZTZiNGUw"]
#               }
#             }
#           ])
#       }
#     }
#     spec = {
#       rules = [
#         {
#           http = {
#             paths = [
#               {
#                 path     = "/*"
#                 pathType = "ImplementationSpecific"
#                 backend  = {
#                   service = {
#                     name = "traefik"
#                     port = {
#                       number = each.key == "internal" ? 8080 : 80
#                     }
#                   } 
#                 }
#               }
#             ]
#           }
#         }
#       ]
#     }
#   }
# }