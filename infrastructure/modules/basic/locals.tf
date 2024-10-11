locals {
  circleci_oidc_url           = "oidc.circleci.com/org/"
  circleci_org_id             = "c53c93bf-aea8-45c3-9aae-984a3f5229a3"
  circleci_oidc_subject_claim = "sub"
  circleci_project_name       = "deliveroo/${local.ecr_repo_name}"
  ecr_desc                    = "A simple nginx `Reverse Proxy` sidecar, which can be placed in front an application's web container to queue requests."
  ecr_repo_name               = "nginx-sidecar"
}
