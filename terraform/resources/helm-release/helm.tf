provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }

}


module "helm_deployment" {
  source              = "../../modules/helm"
  helm_release_name   = var.helm_release_name
  namespace            = var.namespace
}