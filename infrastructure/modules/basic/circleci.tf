resource "circleci_envvar" "aws_ecr_repo" {
  vcs_provider  = "github"
  project_name  = local.circleci_project_name
  variable_name = "AWS_ECR_REPO_URL"
  # input: aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName
  # output: aws_account_id.dkr.ecr.region.amazonaws.com
  variable_value = split("/", aws_ecr_repository.nginx-sidecar.repository_url)[0]
}

resource "circleci_envvar" "oidc_role" {
  vcs_provider   = "github"
  project_name   = local.circleci_project_name
  variable_name  = "OIDC_ROLE_ARN"
  variable_value = aws_iam_role.circleci_oidc.arn
}

resource "circleci_envvar" "aws_region" {
  vcs_provider   = "github"
  project_name   = local.circleci_project_name
  variable_name  = "AWS_DEFAULT_REPO"
  variable_value = "eu-west-1"
}
