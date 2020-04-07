# Create the public subnets
resource "aws_subnet" "threetier_web_subnet" {
  count = "${length(var.availability_zone)}"
  availability_zone = "${element(var.availability_zone, count.index)}"
  vpc_id =  "${aws_vpc.threetier.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr,8,count.index)}"
# map_public_ip_on_launch = true
  tags = {
    Name = "Web Subnet - ${element(var.availability_zone, count.index)}"
  }
}

resource "aws_subnet" "threetier_dmz_subnet" {
  count = "${length(var.availability_zone)}"
  availability_zone = "${element(var.availability_zone, count.index)}"
  vpc_id =  "${aws_vpc.threetier.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr,8,count.index+2)}"
  tags = {
    Name = "DMZ Subnet - ${element(var.availability_zone, count.index)}"
  }
}

# Create the private subnet
resource "aws_subnet" "threetier_was_subnet" {
  count = "${length(var.availability_zone)}"
  availability_zone = "${element(var.availability_zone, count.index)}"
  vpc_id =  "${aws_vpc.threetier.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr,8,count.index+10)}"
  tags = {
    Name = "WAS Subnet - ${element(var.availability_zone, count.index)}"
  }
}

resource "aws_subnet" "threetier_db_subnet" {
  count = "${length(var.availability_zone)}"
  availability_zone = "${element(var.availability_zone, count.index)}"
  vpc_id =  "${aws_vpc.threetier.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr,8,count.index+12)}"
  tags = {
    Name = "DB Subnet - ${element(var.availability_zone, count.index)}"
  }
}

