module "nginx-infra" {
  source   = "../../modules/basic"
  env_name = "production"
  providers = {
    aws           = aws.global_production
    aws.us_east_1 = aws.us_east_1
  }
}
