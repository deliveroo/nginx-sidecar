// A public ECR repo for the image so we can reference a public URL
// instead of needing to use an account ID
resource "aws_ecrpublic_repository" "nginx-sidecar" {
  provider = aws.us_east_1

  repository_name = local.ecr_repo_name

  catalog_data {
    about_text        = local.ecr_desc
    description       = local.ecr_desc
    operating_systems = ["Linux"]
  }
}

// Create a CircleCI user so we are able to push to the public ECR Repo
module "my-app-circleci-user" {
  source = "https://terraform-registry.deliveroo.net/deliveroo/circleci_iam_user/aws"

  namespace           = var.env_name
  github_repo_name    = "nginx-sidecar"
  team_name           = "production-platforms-nec"
  github_organization = "deliveroo"

}
