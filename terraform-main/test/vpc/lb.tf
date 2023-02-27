resource "aws_elb" "example_elb" {
  name               = "example-elb"
  subnets            = [aws_subnet.example_subnet_1.id, aws_subnet.example_subnet_2.id]
  security_groups    = [aws_security_group.web_servers_sg.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb_attachment" "example_elb_attachment" {
  elb_id       = aws_elb.example_elb.id
  instance_id  = aws_instance.example_instance.id
}

# Use Auto Scaling to Automatically Adjust the Number of EC2 Instances:

resource "aws_launch_configuration" "example_lc" {
  image_id        = "ami-0c55b159cbfafe1f0"
  instance_type  = "t2.micro"
  security_groups = [aws_security_group.web_servers_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # install and configure web server software
              EOF
}

resource "aws_autoscaling_group" "example_asg" {
  name                 = "example-asg"
  availability_zones   = ["us-west-2a", "us-west-2b", "us-west-2c"]
  launch_configuration = aws_launch_configuration.example_lc.name
  min_size             = 1
  max_size             = 3

  tag {
    key                 = "Name"
    value               = "example_instance"
    propagate_at_launch = true
  }
}
