# Create route table NAT for WEB, WAS, DB subnet
resource "aws_route_table" "threetier_was_subnet" {
  vpc_id = "${aws_vpc.threetier.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.threetier.id}"
  }
  tags = {
    Name = "WAS Subnet Route Table"
  }
}

resource "aws_route_table" "threetier_db_subnet" {
  vpc_id = "${aws_vpc.threetier.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.threetier.id}"
  }
  tags = {
    Name = "DB Subnet Route Table"
  }
}

resource "aws_route_table" "threetier_web_subnet" {
  vpc_id = "${aws_vpc.threetier.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.threetier.id}"

  }
  tags = {
    Name = "WEB Subnet Route Table"
  }
}

# Create route table internet for DMZ subnet
resource "aws_route_table" "threetier_dmz_subnet" {
  vpc_id = "${aws_vpc.threetier.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "DMZ Subnet Route Table"
  }
}

# Associate the public and private subnets to route table
resource "aws_route_table_association" "threetier_dmz_subnet" {
  count = "${length(var.availability_zone)}"
  subnet_id = "${element(aws_subnet.threetier_dmz_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.threetier_dmz_subnet.id}"
}
resource "aws_route_table_association" "threetier_web_subnet" {
  count = "${length(var.availability_zone)}"
  subnet_id = "${element(aws_subnet.threetier_web_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.threetier_web_subnet.id}"
}

resource "aws_route_table_association" "threetier_was_subnet" {
  count = "${length(var.availability_zone)}"
  subnet_id = "${element(aws_subnet.threetier_was_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.threetier_was_subnet.id}"
}

resource "aws_route_table_association" "threetier_db_subnet" {
  count = "${length(var.availability_zone)}"
  subnet_id = "${element(aws_subnet.threetier_db_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.threetier_db_subnet.id}"
}

