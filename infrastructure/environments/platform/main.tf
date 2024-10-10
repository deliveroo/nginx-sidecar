module "nginx-infra" {
  source   = "../../modules/basic"
  env_name = "platform"
  providers = {
    aws           = aws.global_platform
    aws.us_east_1 = aws.us_east_1
  }
}
