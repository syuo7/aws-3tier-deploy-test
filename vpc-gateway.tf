# Create the Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.threetier.id}"

  tags = {
    Name = "IGW"
  }
}

# Create the Nat Gateway
resource "aws_nat_gateway" "threetier" {
 #count = "${length(var.availability_zone)}"
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id = "${aws_subnet.threetier_dmz_subnet.0.id}"
  depends_on = ["aws_internet_gateway.gw"]
}
