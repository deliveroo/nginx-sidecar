provider "aws" {
  alias  = "global_production"
  region = "eu-west-1"

  default_tags {
    tags = data.roo_tags.global_production.aws_tags
  }

  assume_role {
    role_arn     = data.roo_aws_account.global.terraform_deploy_role_arn
    session_name = "geopoiesis-global_production"
  }
}

// Public ECR repos can only be created in this region
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = data.roo_tags.global_production.aws_tags
  }
  assume_role {
    role_arn     = data.roo_aws_account.global.terraform_deploy_role_arn
    session_name = "geopoiesis-global_eu_east_1_production"
  }
}
provider "circleci" {}
provider "roo" {
  default_env_name        = "production"
  default_ownership_group = "production-platforms-nec"
  default_shard_name      = "global"
}
