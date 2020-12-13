###Create VPC
resource "aws_vpc" "vpcmain" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "vpcmain"
  }
}

###Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id       = "${aws_vpc.vpcmain.id}"
  depends_on   = ["aws_vpc.vpcmain","aws_internet_gateway.vpc_igw"]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc_igw.id}"
  }
  tags = {
          Name = "public_route_table"
  }
}

###Route Table Association 
resource "aws_route_table_association" "public_association" {
  count          = "${length(var.public_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
  depends_on     = ["aws_vpc.vpcmain","aws_route_table.public_route_table","aws_subnet.public_subnets"]
}


###Private Route Table
resource "aws_route_table" "private_route_table" {
  count          = "${length(var.public_subnet_cidr)}"
  vpc_id         = "${aws_vpc.vpcmain.id}"
  depends_on     = ["aws_vpc.vpcmain","aws_internet_gateway.vpc_igw"]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.vpc_ngw[count.index].id}"
}
  tags = { 
          Name = "${format("private_rt-%d", count.index+1)}"
  }
  }

###Route Table Association
resource "aws_route_table_association" "private_association" {
  count          = "${length(var.private_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table[count.index].id}"
  depends_on     = ["aws_vpc.vpcmain","aws_route_table.public_route_table","aws_subnet.private_subnets"]
}

###Route Table Association
resource "aws_route_table_association" "private_association1" {
  count          = "${length(var.private_datasubnet_cidr)}"
  subnet_id      = "${element(aws_subnet.private_datasubnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table[count.index].id}"
  depends_on     = ["aws_vpc.vpcmain","aws_route_table.public_route_table","aws_subnet.private_datasubnets"]
}

###subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "subnet_group"
  subnet_ids = "${aws_subnet.private_datasubnets.*.id}"

  tags = {
    Name = "db_subnet_group"
  }
}

###subnets
resource "aws_subnet" "public_subnets" {
  count                   = "${length(var.public_subnet_cidr)}"
  vpc_id                  = "${aws_vpc.vpcmain.id}"
  cidr_block              = "${element(var.public_subnet_cidr, count.index)}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${element(var.availability_zone, count.index)}"
  depends_on              = ["aws_vpc.vpcmain"]
  tags = {
    Name = "${element(var.public_subnet_names, count.index)}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = "${length(var.private_subnet_cidr)}"
  vpc_id                  = "${aws_vpc.vpcmain.id}"
  cidr_block              = "${element(var.private_subnet_cidr, count.index)}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${element(var.availability_zone, count.index)}"
  depends_on              = ["aws_vpc.vpcmain"]
  tags = {
    Name = "${element(var.private_subnet_names, count.index)}"
  }
}

resource "aws_subnet" "private_datasubnets" {
  count                   = "${length(var.private_datasubnet_cidr)}"
  vpc_id                  = "${aws_vpc.vpcmain.id}"
  cidr_block              = "${element(var.private_datasubnet_cidr, count.index)}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${element(var.availability_zone, count.index)}"
  depends_on              = ["aws_vpc.vpcmain"]
  tags = {
    Name = "${element(var.private_datasubnet_names, count.index)}"
  }
}

