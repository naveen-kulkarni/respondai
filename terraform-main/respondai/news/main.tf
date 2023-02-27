resource "aws_security_group" "webservers" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "${local.vpc_id}" 

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
===========================================================================================

===========================================================================================
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.prefix}/base/vpc_id"
}
data "aws_ssm_parameter" "pub-subnet-a" {
  name = "/${var.prefix}/base/subnet/pub-a/id"
}
data "aws_ssm_parameter" "pub-subnet-b" {
  name = "/${var.prefix}/base/subnet/pub-b/id"
}

data "aws_ssm_parameter" "pvt-subnet-a" {
  name = "/${var.prefix}/base/subnet/pvt-a/id"
}
data "aws_ssm_parameter" "pvt-subnet-b" {
  name = "/${var.prefix}/base/subnet/pvt-b/id"
}

locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  pub_subnet_id_a = data.aws_ssm_parameter.pub-subnet-a.value
  pub_subnet_id_b = data.aws_ssm_parameter.pub-subnet-b.value
  pvt_subnet_id_a = data.aws_ssm_parameter.pvt-subnet-a.value
  pvt_subnet_id_b = data.aws_ssm_parameter.pvt-subnet-b.value
}

resource "aws_security_group" "ssh_access" {
  vpc_id      = "${local.vpc_id}"
  name        = "${var.prefix}-ssh_access"
  description = "SSH access group"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP"
    createdBy = "infra-${var.prefix}/news"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.prefix}-news"
  public_key = "${file("${path.module}/../id_rsa.pub")}"
}

data "aws_ami" "amazon_linux_2" {
 most_recent = true

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }

 filter {
   name = "architecture"
   values = ["x86_64"]
 }

 owners = ["137112412989"] #amazon
}

==============================================================================================
resource "aws_instance" "web-server-a" {
  ami           = "${data.aws_ami.amazon_linux_2.id}"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }

  iam_instance_profile = "${var.prefix}_news_host"

  availability_zone = "${var.region}a"

  subnet_id = local.pub_subnet_id_a

  vpc_security_group_ids = [
    "${aws_security_group.front_end_sg.id}",
    "${aws_security_group.ssh_access.id}"
  ]

  tags = {
    Name = "${var.prefix}-front_end"
    createdBy = "infra-${var.prefix}/news"
  }

connection {
    host = "${self.public_ip}"
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("${path.module}/../id_rsa")}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/provision-docker.sh"
  }
}

  resource "aws_instance" "web-server-b" {
  ami           = "${data.aws_ami.amazon_linux_2.id}"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }

  iam_instance_profile = "${var.prefix}_news_host"

  availability_zone = "${var.region}b"

  subnet_id = local.pub_subnet_id_b

  vpc_security_group_ids = [
    "${aws_security_group.front_end_sg.id}",
    "${aws_security_group.ssh_access.id}"
  ]

  tags = {
    Name = "${var.prefix}-front_end"
    createdBy = "infra-${var.prefix}/news"
  }
  connection {
    host = "${self.public_ip}"
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("${path.module}/../id_rsa")}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/provision-webservice.sh"
  }
}
======================================================================================
output "frontend_url" {
  value = "http://${aws_instance.front_end.public_ip}:8080"
}



