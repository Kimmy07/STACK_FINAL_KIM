#production.tfvars 
region="us-east-1"
availability_zone=["us-east-1a","us-east-1b"]
vpc_cidr="10.0.0.0/16"
public_subnet_names=["public_subnet_1a","public_subnet_1b"]
private_subnet_names=["private_subnet_1a","private_subnet_1b"]
private_datasubnet_names=["private_datasubnet_1a","private _datasubnet_1b"]
public_subnet_cidr=["10.0.0.0/24","10.0.1.0/24"]
private_subnet_cidr=["10.0.2.0/24","10.0.3.0/24"]
private_datasubnet_cidr=["10.0.4.0/24","10.0.5.0/24"]
