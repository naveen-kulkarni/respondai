
#Creating autoscaling group
resource "aws_launch_template" "webservers" {
  name_prefix   = "webservers"
  image_id      = "ami-0c096ca5a3fbca310"
  instance_type = "t2.micro"
}
resource "aws_autoscaling_group" "webservers" {
  availability_zones = ["us-east-2a"]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  launch_template {
    id      = aws_launch_template.webservers.id
    version = "$Latest"
  }
}

#Creating autoscaling launch_template

data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20220406.1-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # Canonical
}
resource "aws_launch_configuration" "nginxserver" {
  name_prefix   = "nginxserver_launch_config"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
}

#Creating autoscaling policy
resource "aws_autoscaling_policy" "simple_scaling" {
  name                   = "simple_scaling_policy"
  scaling_adjustment     = 3
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.appserver.name
}
resource "aws_autoscaling_group" "appserver" {
  availability_zones        = ["us-east-2a"]
  name                      = "appserver"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 100
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.appserver.name
}
resource "aws_launch_configuration" "appserver" {
  name_prefix   = "nginxserver_launch_config"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
}

Creating 	autoscaling schedule

resource "aws_autoscaling_group" "batchprocess_server" {
  availability_zones        = ["us-east-2a"]
  name                      = "batchprocess_server_asg"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 100
  health_check_type         = "ELB"
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  
  launch_template {
    id      = aws_launch_template.batchprocess_servers.id
    version = "$Latest"
  }
}
resource "aws_autoscaling_schedule" "batchprocess_server_autoscaling_schedule" {
  scheduled_action_name  = "batchprocess_server_autoscaling_schedule"
  min_size               = 0
  max_size               = 4
  desired_capacity       = 0
  start_time             = "2022-04-20T18:00:00Z"
  end_time               = "2022-04-22T06:00:00Z"
  autoscaling_group_name = aws_autoscaling_group.batchprocess_server.name
}
resource "aws_launch_template" "batchprocess_servers" {
  name_prefix   = "batchprocess_servers"
  image_id      = "ami-0c096ca5a3fbca310"
  instance_type = "t2.micro"
}

#Create autoscaling attachment

resource "aws_autoscaling_attachment" "webservers_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.webservers.id
  elb                    = aws_elb.webservers_loadbalancer.id
}
resource "aws_launch_template" "webservers" {
  name_prefix   = "webservers"
  image_id      = "ami-0c096ca5a3fbca310"
  instance_type = "t2.micro"
}
resource "aws_autoscaling_group" "webservers" {
  availability_zones = ["us-east-2a"]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  launch_template {
    id      = aws_launch_template.webservers.id
    version = "$Latest"
  }
  
  depends_on = [
    aws_elb.webservers_loadbalancer
  ]
}
resource "aws_elb" "webservers_loadbalancer" {
  name               = "webservers-loadbalancer"
  availability_zones = ["us-east-2a", "us-east-2b"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }
}