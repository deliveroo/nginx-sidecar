resource "circleci_envvar" "aws_ecr_repo" {
  vcs_provider   = "github"
  project_name   = local.circleci_project_name
  variable_name  = "AWS_ECR_REPO_URL"
  variable_value = aws_ecrpublic_repository.nginx-sidecar.repository_uri
}

resource "circleci_envvar" "oidc_role" {
  vcs_provider   = "github"
  project_name   = local.circleci_project_name
  variable_name  = "OIDC_ROLE_ARN"
  variable_value = aws_iam_role.circleci_oidc.arn
}

resource "circleci_envvar" "aws_ecr_repo" {
  vcs_provider   = "github"
  project_name   = local.circleci_project_name
  variable_name  = "ECR_AWS_REGION"
  variable_value = "us-east-1"
}
