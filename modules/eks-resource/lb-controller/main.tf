resource "kubernetes_service_account" "lb_controller_sa" {
  metadata {
    name      = "${var.name}-aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.lb_controller_irsa_arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.1"

  values = [
    yamlencode({
      clusterName = var.cluster_name
      serviceAccount = {
        create = false
        name   = var.service_account_name
      }
      region = var.region
      vpcId  = var.vpc_id
    })
  ]

  depends_on = [kubernetes_service_account.lb_controller_sa]
}

resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  role       = var.lb_controller_irsa_name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}
