
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.prefix}/base/vpc_id"
}

data "aws_ssm_parameter" "pvt-subnet-a" {
  name = "/${var.prefix}/base/subnet/pvt-a/id"
}
data "aws_ssm_parameter" "pvt-subnet-b" {
  name = "/${var.prefix}/base/subnet/pvt-b/id"
}

locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  pvt_subnet_id_a = data.aws_ssm_parameter.pvt-subnet-a.value
  pvt_subnet_id_b = data.aws_ssm_parameter.pvt-subnet-b.value
}
resource "aws_db_subnet_group" "db-subnet" {
name = "DB subnet group"
subnet_ids = ["local.pvt_subnet_id_a", "local.pvt_subnet_id_b"]
}

data "aws_db_snapshot" "db_snapshot" {
most_recent = true
db_instance_identifier = "testinstance"
}

resource "aws_db_instance" "db_test" {
instance_class = "db.t2.small"
identifier = "newtestdb"
username = "test"
password = "Test@54132"
publicly_accessible = false
db_subnet_group_name = "${aws_db_subnet_group.db-subnet.name}"
snapshot_identifier = "${data.aws_db_snapshot.db_snapshot.id}"
vpc_security_group_ids = ["sg-00h62b79"]skip_final_snapshot = true
}

