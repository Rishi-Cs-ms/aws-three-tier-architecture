#IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-app-profile"
  role = aws_iam_role.ec2_role.name
}

#Launch Template (AMI + User Data)

resource "aws_launch_template" "app_lt" {
  name_prefix   = "node-app-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(<<EOF
#!/bin/bash
cd /home/ec2-user/aws-three-tier-demo-backend

SECRET=$(aws secretsmanager get-secret-value \
  --secret-id ${var.db_secret_arn} \
  --query SecretString \
  --output text)

export DB_HOST=$(echo $SECRET | jq -r .host)
export DB_USER=$(echo $SECRET | jq -r .username)
export DB_PASSWORD=$(echo $SECRET | jq -r .password)
export DB_NAME=demo_db
export PORT=3000

pm2 start server.js --name backend
pm2 save
EOF
  )
}

#Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  min_size         = 1
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "node-app"
    propagate_at_launch = true
  }
}

