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

data "aws_iam_policy_document" "circleci_oidc" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = [aws_ecr_repository.nginx-sidecar.arn]
  }

  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "circleci_oidc" {
  name   = "NginxSidecarCircleCI"
  policy = data.aws_iam_policy_document.circleci_oidc.json
}

resource "aws_iam_role_policy_attachment" "circleci_oidc" {
  role       = aws_iam_role.circleci_oidc.name
  policy_arn = aws_iam_policy.circleci_oidc.arn
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "NginxSidecarECRPolicy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      values   = [data.roo_environment.current.apps_aws_organization_path]
      variable = "aws:PrincipalOrgPaths"
    }

    // Only actions that are for uploading images
    actions = [
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
  }

  statement {
    sid    = "NginxSidecarPullECRPolicy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test = "ForAnyValue:StringLike"
      // Pull out the top level org ID and allow any of our accounts to pull
      values   = ["${split("/", data.roo_environment.current.apps_aws_organization_path)[0]}/*"]
      variable = "aws:PrincipalOrgPaths"
    }

    // Actions for any account, i.e. downloading images
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
    ]
  }
}


resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = local.ecr_repo_name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}
