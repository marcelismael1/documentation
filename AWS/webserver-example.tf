# COMMANDS
/*
terraform init
terraform validate
terraform plan
terraform apply
terraform apply --auto-approve
terraform apply -terget aws_instance.web-server
terraform destroy
terraform destroy --auto-approve
terraform destroy -terget aws_instance.web-server
terraform state list
terraform state show aws_instance.web-server
terraform refresh
terraform output
terraform show
*/


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
  region     = "eu-central-1"
  access_key = "access_key"
  secret_key = "secret_key"
}

# in this example a web server will be created and deployed, and in order to do so the below steps will be executed:
# # 1. Create vpc
# # 2. Create Internet Gateway
# # 3. Create Custom Route Table
# # 4. Create a Subnet 
# # 5. Associate subnet with Route Table
# # 6. Create Security Group to allow port 22,80,443
# # 7. Create a network interface with an ip in the subnet that was created in step 4
# # 8. Assign an elastic IP to the network interface created in step 7
# # 9. Create Ubuntu server and install/enable apache2


# 1. Create vpc
resource "aws_vpc" "web-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "Webserver-VPC"
  }
}
#------------------------------------------
# # 2. Create Internet Gateway
resource "aws_internet_gateway" "web-gw" {
  vpc_id = aws_vpc.web-vpc.id

  tags = {
    Name = "webserver-gw"
  }
}
#------------------------------------------
# # 3. Create Custom Route Table
# define default route
resource "aws_route_table" "web-route" {
  vpc_id = aws_vpc.web-vpc.id

  route {
    cidr_block = "0.0.0.0/0"   # for all traffic (NOT BEST PRACTICE)
    gateway_id = aws_internet_gateway.web-gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.web-gw.id
  }

  tags = {
    Name = "web-default-route"
  }
}
#------------------------------------------
# # 4. Create a Subnet 
# create a subnet in side the VPC, it is better to assign the subnet to availabitiy zone
resource "aws_subnet" "web-subnet" {
  vpc_id     = aws_vpc.web-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"           # set availabity zone the the subnet will be in

  tags = {
    Name = "web-subnet"
  }
}
#------------------------------------------
# # 5. Associate subnet with Route Table
# assiosiate the routing table witht the subnet we just created
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.web-route.id
}
#------------------------------------------
# # 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "web-allow" {
  name        = "allow_web"
  description = "Allow web and managment inbound traffic"
  vpc_id      = aws_vpc.web-vpc.id          # security group is assigned to the VPCs

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]     # ||| NOT BEST PRACTICE ||| & we use list when there are multiple option
  }
ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]     # ||| NOT BEST PRACTICE ||| & we use list when there are multiple option
  }
ingress {
    description = "HTTPS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["1.1.1.1/32", "2.2.2.2/32" ]     # ||| BEST PRACTICE |||  set allowed ips 
  }

  egress {
    from_port   = 0                 # port range
    to_port     = 0                 # port range
    protocol    = "-1"              # allow all protocols
    cidr_blocks = ["0.0.0.0/0"]     # to all destinations
  }

  tags = {
    Name = "allow_web"
  }
}
#------------------------------------------
# # 7. Create a network interface with an ip in the subnet that was created in step 4
# create an interface and give it an ip from the subnet
resource "aws_network_interface" "web-nic" {
  subnet_id       = aws_subnet.web-subnet.id
  private_ips     = ["10.0.1.50"]                       # an IP from the subnet a list becasue we can give the interface multiple ips
  security_groups = [aws_security_group.web-allow.id]   # assign a security group to the interface

/* 
  attachment {                                          # we can attach it to already existing instance
    instance     = aws_instance.test.id
    device_index = 1
  }
*/
}
#------------------------------------------
# # 8. Assign an elastic IP to the network interface created in step 7
# create public ip and connect it to private ip
resource "aws_eip" "web-eip" {
  network_interface         = aws_network_interface.web-nic.id    # associate to nic
  associate_with_private_ip = "10.0.1.50"                         # to which ip private ip of the nic (nic can have more than one ip)
  depends_on                = [aws_internet_gateway.web-gw]           # list dependencies, in our case only the gateway (without the ID)
  vpc      = true                   # if EIP in VPC or not
}
#------------------------------------------
# # 9. Create Ubuntu server and install/enable apache2
# Create an instnce
resource "aws_instance" "web-server" {
  ami = "ami-0767046d1677be5a0"
  instance_type = "t2.micro"
  availability_zone = "eu-central-1a" 
  key_name          = "ama-key"                # login key
  
  #NOTE:  Notice that we dont connect the instance to VPC or subnet we only add the interface which we did all the cofig for before.
  network_interface {
    network_interface_id = aws_network_interface.web-nic.id
    device_index         = 0                                    # index of the interface
  }

  # Commands to run once the machine created
    user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 sudo bash -c 'echo "<h1>your very first web server<h1>" > /var/www/html/index.html'
                 EOF

  tags = {
  	Name = "WebServer"
    type = "test_instance"
  }
}
#------------------------------------------



# OUTPUT Usefull informations after applying
output "print_webserver_public_ip"{
    value = aws_eip.web-eip.public_ip       # point to a certain parameter in this case the public_ip of the eip we created
    }

output "server_private_ip" {                # print private ip
   value = aws_instance.web-server.private_ip

    }  

output "server_id" {                        # print instance id
   value = aws_instance.web-server.id
    }
