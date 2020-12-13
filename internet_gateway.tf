###create internet gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = "${aws_vpc.vpcmain.id}"

  tags = {
    Name = "vpc_igw"
  }
  depends_on    = ["aws_vpc.vpcmain"]
}

#EIP
resource "aws_eip" "vpc_eip" {
  vpc         = true
  count       = "${length(var.public_subnet_cidr)}"
  depends_on  = ["aws_internet_gateway.vpc_igw"]
  tags = {
	Name  = "${format("my_nat_eip-%d", count.index+1)}"
 }
}

###create nat gateway
resource "aws_nat_gateway" "vpc_ngw" {
  allocation_id  = "${aws_eip.vpc_eip[count.index].id}"
  count          = "${length(var.public_subnet_cidr)}"
  subnet_id      = "${aws_subnet.public_subnets[count.index].id}"
  depends_on     = ["aws_vpc.vpcmain","aws_eip.vpc_eip","aws_subnet.public_subnets"]
  tags           = {
        Name    = "${format("nat_gateway-%d", count.index+1)}"
 }
}
