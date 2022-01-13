resource "aws_lb" "front_end" {
  name               = "front-end"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.front_end_80.arn
    type             = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end_443" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_iam_server_certificate.webserver_cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.front_end_443.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "front_end_80" {
  name     = "front-end-80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.wordpress.id
}

resource "aws_lb_target_group" "front_end_443" {
  name     = "front-end-443"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.wordpress.id
}

resource "aws_lb_target_group_attachment" "front_end_443" {
  target_group_arn = aws_lb_target_group.front_end_443.arn
  target_id        = aws_instance.webserver.id
  port             = 443
}
