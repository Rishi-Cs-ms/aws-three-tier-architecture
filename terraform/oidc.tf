# Reference the existing IAM Role
# Note: You MUST manually ensure this role's trust relationship allows the repo: Rishi-Cs-ms/aws-three-tier-architecture
# It should look like: "token.actions.githubusercontent.com:sub": "repo:Rishi-Cs-ms/aws-three-tier-architecture:*"

# New IAM Policy for Three-Tier Project Frontend & Backend
resource "aws_iam_role_policy" "three_tier_deploy" {
  name = "three-tier-deploy-policy"
  role = "github-actions-portfolio" # The name of your existing role

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

# Output the ARN for clarity (referencing the existing role)
data "aws_iam_role" "existing_github_role" {
  name = "github-actions-portfolio"
}

output "github_actions_role_arn" {
  value = data.aws_iam_role.existing_github_role.arn
}
