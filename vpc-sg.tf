# A security group for the ELB so it is acceesible via the web
resource "aws_security_group" "elb" {
  name = "nginx_elb"
  description = "elb for just access to nginx"
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

  # HTTP access from the VPC
  ingress {
    from_port = 80
    to_port = 80
    protocol ="tcp"
    cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
  }

  # Open any connection for same group
  ingress {
    from_port = 0
    to_port = 0
    protocol ="-1"
    self = true
  }

  # Open ssh connection from bastion host
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.10.2.0/24"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Set Bastion security group
resource "aws_security_group" "bastion" {
  name = "bastion group"
  vpc_id = "${aws_vpc.threetier.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
