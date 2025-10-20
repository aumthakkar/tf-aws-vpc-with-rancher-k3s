resource "aws_lb" "my_lb" {
  name = "${var.name_prefix}-lb"

  security_groups = [aws_security_group.my_security_groups["public"].id]
  subnets         = aws_subnet.my_public_subnets[*].id

  idle_timeout = 300

  tags = {
    Name = "${var.name_prefix}-loadbalancer"
  }
}

resource "aws_lb_target_group" "my_lb_target_group" {
  lifecycle {
    ignore_changes        = [name] # as every time during a new apply due to uuid() name will change
    create_before_destroy = true   #for listener to go to if the tg changes
  }

  name   = "${var.name_prefix}-lb-tg"
  vpc_id = aws_vpc.my_vpc.id

  port     = var.tg_port     # 80
  protocol = var.tg_protocol # "HTTP"

  health_check {
    healthy_threshold   = var.lb_healthy_threshold   #2
    unhealthy_threshold = var.lb_unhealthy_threshold #2
    interval            = var.lb_interval            #3
    timeout             = var.lb_timeout             # 30
  }

  tags = {
    Name = "${var.name_prefix}-lb-target-group-${substr(uuid(), 0, 3)}"
  }
}

resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = var.lb_listener_port     #80
  protocol          = var.lb_listener_protocol # "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_lb_target_group.arn
  }

  tags = {
    Name = "${var.name_prefix}-lb-listener"
  }
}

