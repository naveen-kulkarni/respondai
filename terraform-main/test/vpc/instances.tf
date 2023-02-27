resource "aws_security_group" "allow_http" {
  name_prefix = "allow-http"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-http"
  }
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow-ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
  }
}

# Create EC2 instances
resource "aws_launch_configuration" "main" {
  name_prefix          = "my-launch-config"
  image_id             = var.ami_id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
  key_name             = var.key_name
  user_data            = "${file("userdata.sh")}"
  associate_public_ip_address = true
}

===================================================
resource "aws_instance" "example_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id

  user_data = <<-EOF
              #!/bin/bash
              # install and configure web server software
              EOF

  security_groups = [aws_security_group.web_servers_sg.id]
}

# Deploy RDS Instance as the Database Backend:

resource "aws_db_instance" "example_db_instance" {
  engine            = "mysql"
  instance_class    = "db.t2.micro"
  name              = "example_db"
  username          = "example_user"
  password          = "example_password"
  allocated_storage = 20

  subnet_group_name = "example_db_subnet_group"
  parameter_group_name = "example_db_parameter_group"
}
