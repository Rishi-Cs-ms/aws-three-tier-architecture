#Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "node-app-tg-three-tier"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

#Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "node-app-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "node-app-alb"
  }
}

#Listener (HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

#Attach ASG to Target Group
resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.app_tg.arn
}

