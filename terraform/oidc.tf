# Managed existing IAM Role to edit Trust Relationship
resource "aws_iam_role" "github_actions" {
  name = "github-actions-portfolio"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::458130036240:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:*:*"
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# New IAM Policy for Three-Tier Project Frontend & Backend
resource "aws_iam_role_policy" "three_tier_deploy" {
  name = "three-tier-deploy-policy"
  role = aws_iam_role.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "FrontendS3Access"
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.frontend_bucket_name}",
          "arn:aws:s3:::${var.frontend_bucket_name}/*"
        ]
      },
      {
        Sid      = "CloudFrontInvalidation"
        Effect   = "Allow"
        Action   = "cloudfront:CreateInvalidation"
        Resource = "*" 
      },
      {
        Sid      = "BackendSSMUpdate"
        Effect   = "Allow"
        Action   = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Sid      = "ASGRefresh"
        Effect   = "Allow"
        Action   = [
          "autoscaling:StartInstanceRefresh",
          "autoscaling:DescribeAutoScalingGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
