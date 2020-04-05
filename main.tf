provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "TaeilSeok"
    
    workspaces {
      name = "aws-threetier-deploy-test"
    }
  }
}

# Create New VPC
resource "aws_vpc" "threetier" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  
  tags = {
    Name = "threetier vpc"
  }
}

# Initialize availability zone data from AWS
data "aws_availability_zones" "available" {}

# Create the private subnets
resource "aws_subnet" "threetier_vpc_private_subnet" {
  count = "${length(var.availability_zone)}"
  availability_zone = "${element(var.availability_zone, count.index)}"
  vpc_id =  "${aws_vpc.threetier.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr,8,count.index)}"
  tags = {
    Name = "Private Subnet - ${element(var.availability_zone, count.index)}"
  }
}

# Create the public subnets
resource "aws_subnet" "threetier_vpc_public_subnet" {
  count = "${length(var.availability_zone)}"
  availability_zone = "${element(var.availability_zone, count.index)}"
  vpc_id =  "${aws_vpc.threetier.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr,8,count.index+10)}"
  tags = {
    Name = "Public Subnet - ${element(var.availability_zone, count.index)}"
  }
}

# Create the Internet gateway
resource "aws_internet_gateway" "elb" {
  vpc_id = "${aws_vpc.threetier.id}"

  tags = {
    Name = "IGW for elb"
  }
}

# Create the EIP
resource "aws_eip" "elb_eip" {
  vpc = true
  depends_on = ["aws_internet_gateway.elb"]
}

# Create the Net Gateway
resource "aws_nat_gateway" "threetier" {
  allocation_id = "${aws_eip.elb_eip.id}"
  subnet_id = "${element(aws_subnet.threetier_vpc_public_subnet.*.id, 0)}"
  depends_on = ["aws_internet_gateway.elb"]
}

# Create route table NAT for Private subnet
resource "aws_route_table" "threetier_vpc_private_subnet" {
  vpc_id = "${aws_vpc.threetier.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.threetier.id}"
  }
  tags = {
    Name = "Private Subnet Route Table"
  }
}

# Associate the public and private subnets to route table
#resource "aws_route_table_association" "threetier_vpc_public_subnet" {
# count = "${length(var.availability_zone)}"
# subnet_id = "${element(aws_subnet.threetier_vpc_public_subnet.*.id, count.index)}"
# route_table_id = "${aws_route_table.threetier_vpc_public_subnet.id}"
#}

resource "aws_route_table_association" "threetier_vpc_private_subnet" {
  count = "${length(var.availability_zone)}"
  subnet_id = "${element(aws_subnet.threetier_vpc_private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.threetier_vpc_private_subnet.id}"
}

# A security group for the ELB so it is acceesible via the web
resource "aws_security_group" "elb" {
  name = "nginx_elb"
  description = "elb for access to nginx where private subnet"
  vpc_id = "${aws_vpc.threetier.id}"
  
  #  HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    }
    
  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Set Default security group
resource "aws_security_group" "threetier_default" {
  name = "threetier_default"  
  description = "default security group"
  vpc_id = "${aws_vpc.threetier.id}"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port = 80
    to_port = 80
    protocol ="tcp"
    cidr_blocks = ["10.10.10.0/24"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }
}

resource "aws_elb" "elb" {
  name = "elb"
  
  subnets = ["${aws_subnet.threetier_vpc_public_subnet.0.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances = ["${aws_instance.web.0.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}

resource "aws_instance" "web" {
  count = "${length(var.availability_zone)}"
#  connection {
#    user = "ubuntu"
#  }
  
  instance_type = "t2.micro"
  ami = "ami-0c5a717974f63b04c"
  vpc_security_group_ids = [ "${aws_security_group.threetier_default.id}"]
  
  subnet_id = "${element(aws_subnet.threetier_vpc_private_subnet.*.id, count.index)}"
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}
