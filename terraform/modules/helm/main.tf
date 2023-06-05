resource "helm_release" "example" {
  name       = var.helm_release_name
  chart      = "./../../../helmchart/python-app/"
  values = ["${file("${path.module}/helm-values/values.yaml")}"]
}