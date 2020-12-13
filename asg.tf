##auto scaling launch config public
resource "aws_launch_configuration" "asg_launch_pub" {
  name                        = "Pub_ASG_Launch_Config"
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.public_security_group.id}"]
  associate_public_ip_address = "true"
  key_name                    = "${var.key_name_public}"
  user_data                   = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd.service
              systemctl enable httpd.service
              echo "Terraform, loadbalancer, auto-scaling group, private and public subnets. : $(hostname -f)" > /var/www/html/index.html
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
#Autoscaling Group
resource "aws_autoscaling_group" "public_asg" {
  name                      = "${var.public_asg}"
  max_size                  = "3"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = "30"
  health_check_type         = "ELB"
  default_cooldown          = "30"
  #target_group_arns         = ["${aws_alb_target_group.target_group.arn}"]
  launch_configuration      = "${aws_launch_configuration.asg_launch_pub.name}"
  vpc_zone_identifier       = "${aws_subnet.public_subnets.*.id}"
  lifecycle {
    create_before_destroy = true
  }
tag {
    key                 = "Name"
    value               = "ASG-Pub"
    propagate_at_launch = true
  }
  }

#auto scaling launch config private
resource "aws_launch_configuration" "asg_launch_priv" {
  name 			      = "Priv_ASG_Launch_Config" 
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.private_security_group.id}"]
  associate_public_ip_address = "true"
  key_name                    = "${var.key_name_private}"
  user_data                   = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd.service
              systemctl enable httpd.service
              echo "Terraform, loadbalancer, auto-scale group, private and public subnets. : $(hostname -f)" > /var/www/html/index.html
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "private_asg" {
  name                      = "${var.private_asg}"
  max_size                  = "3"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = "30"
  health_check_type         = "ELB"
  default_cooldown          = "30"
  launch_configuration      = "${aws_launch_configuration.asg_launch_priv.name}"
  vpc_zone_identifier       = "${aws_subnet.private_subnets.*.id}"
  lifecycle {
    create_before_destroy = true
  }
tag {
    key                 = "Name"
    value               = "ASG-PRIV"
    propagate_at_launch = true
  }
}

###loadbalancer

resource "aws_alb" "Final_LB" {
  name                       = "final-loadbalancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.lb_security_group.id}"]
  subnets                    = "${aws_subnet.public_subnets.*.id}"
  depends_on                 = ["aws_subnet.public_subnets","aws_security_group.lb_security_group"]
  tags = {
      Name = "production loadbalancer"
  }
}

  #Target Group
  resource "aws_alb_target_group" "final_target_group" {
  name         = "final-tg"
  port         = "80"
  protocol     = "HTTP"
  vpc_id       = "${aws_vpc.vpcmain.id}"
  depends_on   = ["aws_vpc.vpcmain"]
  health_check   {
                    path                = "/"
                    port                = "80"
                    protocol            = "HTTP"
                    healthy_threshold   = "5"
                    unhealthy_threshold = "2"
                    interval            = "5"
                    timeout             = "4"
                    matcher             = "200"
  }
  tags = {
      Name = "target_group"
  }
}

#Target Group Attachment
resource "aws_alb_target_group_attachment" "target_group_attachment" {
  target_group_arn = "${aws_alb_target_group.final_target_group.arn}"
  count            = "${length(var.public_subnet_cidr)}"
  target_id        = "${element(aws_instance.PublicEC2.*.id, count.index)}"
  port             = "80"
}

#listener front end
resource "aws_alb_listener" "listner" {
  load_balancer_arn  = "${aws_alb.Final_LB.arn}"
  port               = "80"
  protocol           = "HTTP"
  depends_on         = ["aws_alb.Final_LB","aws_alb_target_group_attachment.target_group_attachment"]
    default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.final_target_group.arn}"
  }
}


