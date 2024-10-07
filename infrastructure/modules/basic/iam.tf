// Add to CircleCI-IAM-Users to get access to the shared IAM Policies
// needed to work with ECR and Lambda S3 bucket
resource "aws_iam_user_group_membership" "circleci_users" {
  user = module.my-app-circleci-user.name
  groups = [
    "CircleCI-IAM-Users"
  ]
}

data "aws_iam_policy_document" "assume_policy_circleci_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.circleci_oidc_url}${local.circleci_org_id}"]
    }

    condition {
      test     = "StringLike"
      variable = format("%s%s:%s", local.circleci_oidc_url, local.circleci_org_id, local.circleci_oidc_subject_claim)
      values   = [format("org/%s/project/*/user/*/vcs-origin/github.com/%s/vcs-ref/*", local.circleci_org_id, local.circleci_project_name)]
    }
  }
}

resource "aws_iam_role" "circleci_oidc" {
  name               = "NginxSidecarCircleCiOICDAccess"
  assume_role_policy = data.aws_iam_policy_document.assume_policy_circleci_oidc.json
}

resource "aws_iam_role_policy_attachment" "circleci_oidc" {
  role       = aws_iam_role.circleci_oidc.name
  policy_arn = data.aws_iam_policy.circleci_oidc.arn
}
