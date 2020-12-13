###EC2 Instances
resource "aws_instance" "PublicEC2" {
  count                   = "${length(var.public_subnet_cidr)}"
  ami                     = "${var.ami}"
  instance_type           = "${var.instance_type}"
  subnet_id               = "${aws_subnet.public_subnets[count.index].id}"
  vpc_security_group_ids  = ["${aws_security_group.public_security_group.id}"]
  key_name                = "${var.key_name_public}"
  depends_on              = ["aws_vpc.vpcmain","aws_subnet.public_subnets","aws_security_group.public_security_group"]
  tags = {
    Name = "${format("Bastion-%d", count.index+1)}"
  }
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd.service
              systemctl enable httpd.service
              echo "Terraform for STACK Final Exam. : $(hostname -f)" > /var/www/html/index.html
              EOF
}

resource "aws_instance" "PrivateEC2" {
  count                  = "${length(var.private_subnet_cidr)}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.private_subnets[count.index].id}"
  vpc_security_group_ids = ["${aws_security_group.private_security_group.id}"]
  key_name               = "${var.key_name_private}"
  depends_on             = ["aws_vpc.vpcmain","aws_subnet.private_subnets","aws_security_group.private_security_group"]
  tags = { 
    Name = "${format("App-Server-%d", count.index+1)}"
  }
  user_data = <<-EOF
 #!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
groups
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

#Secure the database server
set timeout 10
sudo systemctl start mariadb

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"\r\"

expect \"Change the root password?\"
send \"y\r\"
expect \"New password:\"
send \"password\r\"
expect \"Re-enter new password:\"
send \"password\r\"
expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

sudo systemctl stop mariadb
sudo systemctl enable mariadb

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo systemctl start mariadb

mysql --user=root --password= << eof
CREATE USER 'wordpress-user'@'localhost' IDENTIFIED BY 'password';
CREATE DATABASE wordpressdb;
GRANT ALL PRIVILEGES ON wordpressdb.* TO "wordpress-user"@"localhost";
FLUSH PRIVILEGES;
eof

cp wordpress/wp-config-sample.php wordpress/wp-config.php

sed -i "s/database_name_here/wordpressdb/g" wordpress/wp-config.php
sed -i "s/username_here/wordpress-user/g" wordpress/wp-config.php
sed -i "s/password_here/password/g" wordpress/wp-config.php


cp -r wordpress/* /var/www/html/

sed -i "s/AllowOverride None/AllowOverride All/g" /etc/httpd/conf/httpd.conf


sudo yum install php-gd
sudo yum list installed | grep php
yum list | grep php
sudo yum install php72-gd
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl restart httpd

sudo systemctl enable httpd && sudo systemctl enable mariadb
sudo systemctl status mariadb
sudo systemctl start mariadb
sudo systemctl start mariadb
sudo systemctl status httpd
sudo systemctl start httpd

              EOF
}

###Create Security Groups
resource "aws_security_group" "public_security_group" {
    name        = "public-sg"
    description = "public security"
    vpc_id      = "${aws_vpc.vpcmain.id}"


ingress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }
    tags = {
        Name = "public_security_group"
    }
    depends_on = ["aws_vpc.vpcmain"]
}



resource "aws_security_group" "private_security_group" {
    name        = "private-sg"
    description = "private security group"
    vpc_id      = "${aws_vpc.vpcmain.id}"

    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      security_groups = ["${aws_security_group.public_security_group.id}"]
    }

    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }
    tags = {
        Name = "private_security_group"
    }
    depends_on = ["aws_vpc.vpcmain"]
}

###Load Balancer Security Group
resource "aws_security_group" "lb_security_group" {
    name        = "lb-security"
    description = "Internet reaching access for public ec2s"
    vpc_id      = "${aws_vpc.vpcmain.id}"

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
    tags = {
        Name = "lb_public_security"
    }
    depends_on = ["aws_vpc.vpcmain"]
}


