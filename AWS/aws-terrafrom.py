aws-terraform

# install Terraform
> For windows: download terraform zip file, extractit and place it somewhere > chanfe PATH variable and terraform.exe location
> for MAC: brew install terraform
> Linux: download zip file > extract it >  mv the file to /usr/loca/bin

# Use Vcode with Terraform
install an extension called Terrafrom from HashiCorp

Terrafrom files are ".tf" extentions


########################
### adding providers ###
########################

# Terrafrom supports a lot of providers so at the begginnig of terraform frile we need to specify the provider
# for AWS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# NOTE it is not recommended to use hardcoded credentials instead you can environments variables or credentials file


provider "aws" {
  region                  = "us-west-2"
  shared_credentials_file = "/Users/tf_user/.aws/creds"
  profile                 = "customprofile"
}

########################
### Handle Resources ###
########################

resource "<provider>_<resource_type>" "Terrafrom_Name" {
  config options ..
  key1 = 
  key2 = 
}

################################
### Terraform Basic Commands ###
################################
# Navigate to the project dirctory and init to install basic tools and packages
terraform init

# To test what would happend and what will this tf file do  ( add, changes or distroy)

terraform plan

# to excute the terraform file 
terraform apply
terraform apply --auto-approve # unattended apply


# NOTE: always plan before apply

# NOTE: If we applied tjhe same terraform file multiple time it will not create or make the same changes again and rather it will
# do nothing since the terraformm file s more like  a BLUE PRINT of how we want the infrastructure to look like

########################
### Create instances ###
########################
# Create an instance
resource "aws_instances" "my_first_instance" {
  ami = "ami-76876546768c4e1"
  instance_type = "t2_micro"
}


# if we run terraform plan on this file we can see the changes that will be maid. (a new instances will be affected and createed but most of the fields are empty)
# and we make those changes when we type terraform apply.
# if we run this file again no thing will change becasuse terraform preserves the state of the infrastructure
# IF we made a change as below

resource "aws_instances" "my_first_instance" {
  ami = "ami-76876546768c4e1"
  instance_type = "t2_micro"
  tags = {
  	Name = "Ubuntu"
  }
}

# If we make terraform plan we notice that the result is change on the instance that we want to change with all its details (It was empty before we created it)
# and the indication that a tag will be added can be visible.


# DESTROY
# to delete the instance we use, this will destroy a full infrastructure
terraform destroy


# delete instances
# We can delete the instance by deleteing the instance form the tf and it can be delleted easiely



##############################
### Create VPC and Subnets ###
##############################
# we want to create a VPC and a subnet and attach this subnets to that VPC

resource "aws_vpc" "first_VPC" {
  cidr_block       = "10.0.0.0/16" # the main subnets that subnets should be created from

  tags = {
    Name = "VPC name". 				# VPC aws name
  }
}

resource "aws_subnet" "example_subnet" {
  vpc_id     = aws_vpc.first_VPC.id 			# reference to the created VPC
  cidr_block = "10.0.1.0/24"					# cidr_block shuld be asubnet form the cidr ot the referenced vpc

  tags = {
    Name = "subnet01"							# aws subnet name
  }
}


# REFERENCE RESOURCES
# To reference a aresource we use the below form
<resource_type>.<Terrafrom_Name>.id
aws_vpc.first_VPC.id                   # reference to first_VPC VPC
aws_vpc.main.id                        # reference to main default VPC


#######################
### Terraform Files ###
#######################

 .terraform
# this is a folder that contains all the provider plugins whhen we issue "terraform init" 
# Deleteing it will no apply the tf file. but we can alwasys init again

terraform.tfstate
# as we learned earlier that terraform applys the files to save the state of the infrastructure and to do so it uses this file
# to save infrastructure state.
# deleting this file will miss up everything so be carefull



