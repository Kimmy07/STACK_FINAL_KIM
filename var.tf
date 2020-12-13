variable "ami" {
        default = "ami-0947d2ba12ee1ff75"
}

variable "instance_type" {
         default = "t2.micro"
}

variable "availability_zone" {
         type    = "list"
	 default = ["us-east-1a",
		    "us-east-1b",
		    "us-east-1c"]
}

variable "public_subnet_cidr" {
         type = "list"
}

variable "private_subnet_cidr" {
         type = "list"
}

variable "private_datasubnet_cidr" {
         type = "list"
}

variable "public_subnet_names" {
        type = "list"
}

variable "private_subnet_names" {
        type = "list"
}
variable "private_datasubnet_names" {
        type = "list"
}

variable "subnet_id" {
        default = ""
}


variable "key_name_public" {
        default = "stackkp"
}

variable "key_name_private" {
        default = "MyEC2KP_Priv(NEW)"
}

variable "user_data" {
        default = ""
} 


variable "public_asg" {
        default = "public_asg"
}

variable "private_asg" {
        default = "private_asg"
}

variable "username" {
        default = "wordpressuser"
}

variable "password" {
        default = "password"
}

variable "route53_name" {
        default = "stack-kimberly.com"
}

variable "database_name" {
        default = "mydb"
}

variable "engine" {
        default = "aurora-mysql"
}

variable "engine_version" {
        default = "5.7.mysql_aurora.2.07.2"
}

variable "rdscluster" {
	default = "rdscluster"
}
variable "origin_id" {
        default = "S3-final-exam-kim"
}
variable "domain_name" {
        default = "final-exam-kim.s3.amazonaws.com"
}
variable "bucket" {
        default = "final-exam-logs.s3.amazonaws.com"
}

variable "name" {
        default = "database"
}
