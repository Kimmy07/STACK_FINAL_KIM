#EFS 
resource "aws_efs_file_system" "EFS" {
  tags = {
    Name = "MyProduct"
  }
}


#EFS  MOUNT TARGET
resource "aws_efs_mount_target" "alpha" {
  count                          = "${length(var.private_datasubnet_cidr)}"
  file_system_id                 = "${aws_efs_file_system.EFS.id}"
  subnet_id                      = "${aws_subnet.private_datasubnets[count.index].id}"
  security_groups                = ["${aws_security_group.private_security_group.id}"]
}


