###rds_aurora

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 2.0"
  
   database_name                       = "${var.database_name}"
   name                                = "${var.name}"

  
  username                            = "${var.username}"
  password                            = "${var.password}"
  iam_database_authentication_enabled = false

  engine                          = "${var.engine}"
  engine_version                  = "${var.engine_version}"

  vpc_id                          = "${aws_vpc.vpcmain.id}"
  subnets                         = "${aws_subnet.private_datasubnets.*.id}"
  db_subnet_group_name            = "${aws_db_subnet_group.db_subnet_group.id}"
  create_security_group           = "false"
  publicly_accessible             = "false"
  replica_count                   = 1
  port                            = 3306
  allowed_security_groups         = ["${aws_security_group.public_security_group.id}"]
  vpc_security_group_ids          = ["${aws_security_group.private_security_group.id}"] 
  instance_type                   = "db.r5.large"

  tags                             = {
    Environment = "dev"
    Terraform   = "true"
  }
}

###aws_rds_cluster
resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier      = "${var.rdscluster}"
  engine                  = "${var.engine}"
  engine_version          = "${var.engine_version}"
  availability_zones      = "${var.availability_zone}"
  database_name           = "${var.database_name}"
  master_username         = "${var.username}"
  master_password         = "${var.password}"
  skip_final_snapshot     = "true"
}

