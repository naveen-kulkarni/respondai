data "aws_ssm_parameter" "pub-subnet-a" {
  name = "/${var.prefix}/base/subnet/pub-a/id"
}
data "aws_ssm_parameter" "pub-subnet-b" {
  name = "/${var.prefix}/base/subnet/pub-b/id"
}

# Create a new load balancer
resource "aws_elb" "terra-elb" {
  name               = "terra-elb"
  subnets = aws_subnet.public-subnet-*.*.id
  security_groups = [aws_security_group.front-end.id]

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
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  instances                   = [aws_instance.web-server-a.id, aws_instance.web-server-b.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "terraform-elb"
  }
}

output "elb-dns-name" {
  value = aws_elb.terra-elb.dns_name
}