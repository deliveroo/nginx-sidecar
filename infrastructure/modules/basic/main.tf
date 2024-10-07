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

