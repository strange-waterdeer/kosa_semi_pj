# Classic Load Balancer
resource "aws_elb" "web_elb" {
  name            = "pj-web-elb"
  subnets         = aws_subnet.public[*].id
  security_groups = [aws_security_group.sg_web.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = aws_instance.web_server[*].id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "pj_web_elb"
  }
}
