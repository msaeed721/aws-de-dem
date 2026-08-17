# ============================================================
# GITHUB ACTIONS OIDC PROVIDER
# ============================================================

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Project   = "AWS Data Engineering Demo"
    ManagedBy = "Terraform"
  }
}


# ============================================================
# GITHUB ACTIONS DEPLOY ROLE
# ============================================================

resource "aws_iam_role" "github_actions" {
  name = "github-actions-aws-de-demo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud"        = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:repository" = "msaeed721/aws-de-dem"
        }

        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:msaeed721/aws-de-dem:ref:refs/heads/main",
            "repo:msaeed721@*/aws-de-dem@*:ref:refs/heads/main"
          ]
        }
      }
    }]
  })

  tags = {
    Project   = "AWS Data Engineering Demo"
    ManagedBy = "Terraform"
  }
}


# ============================================================
# PERMISSIONS FOR OUR DEMO INFRASTRUCTURE ONLY
# ============================================================

resource "aws_iam_role_policy" "github_actions" {
  name = "GitHubActionsDemoDeploy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # ------------------------------------------------------
      # Terraform state + demo data lake
      # ------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "s3:*"
        ]

        Resource = [
          "arn:aws:s3:::aws-de-demo-029633610686",
          "arn:aws:s3:::aws-de-demo-029633610686/*",

          "arn:aws:s3:::aws-de-demo-tfstate-029633610686",
          "arn:aws:s3:::aws-de-demo-tfstate-029633610686/*"
        ]
      },

      # ------------------------------------------------------
      # AWS services used by this demo
      # ------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "glue:*",
          "athena:*",
          "lambda:*",
          "logs:*",
          "cloudwatch:*",
          "sns:*"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------
      # Manage IAM roles used by Glue and Lambda
      # ------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:ListRoleTags",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole"
        ]

        Resource = [
          "arn:aws:iam::029633610686:role/AWSGlueServiceRole-aws-de-demo",
          "arn:aws:iam::029633610686:role/lambda-pharmacy-batch-validator"
        ]
      },

      # ------------------------------------------------------
      # Read its own GitHub Actions IAM role
      #
      # IMPORTANT:
      # GitHub can inspect this role during terraform plan,
      # but cannot modify its own trust policy or permissions.
      # ------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "iam:GetRole",
          "iam:ListRoleTags",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies"
        ]

        Resource = "arn:aws:iam::029633610686:role/github-actions-aws-de-demo"
      },

      # ------------------------------------------------------
      # Read GitHub OIDC provider configuration
      # ------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders"
        ]

        Resource = "*"
      }
    ]
  })
}


# ============================================================
# OUTPUT
# ============================================================

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}