resource "aws_ecr_repository" "nginx-sidecar" {
  name = local.ecr_repo_name
  image_scanning_configuration {
    scan_on_push = true
  }
}
