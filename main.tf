provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
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

# Create the NAT EIP
resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = ["aws_internet_gateway.gw"]
}

# Create the ALB for nginx instance load balancing.
resource "aws_alb" "alb" {
  name = "nginx-alb"
  internal = false
  subnets = "${aws_subnet.threetier_dmz_subnet.*.id}"
  security_groups = ["${aws_security_group.elb.id}",
                     "${aws_security_group.threetier_default.id}"
                    ]
  tags = {
    Name = "Nginx ALB"
  }
  lifecycle { create_before_destroy = true }
}

# Set the ELB listener.
resource "aws_alb_listener" "nginx" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = "80"
  protocol = "HTTP"
  
  default_action { 
    type = "forward"
    target_group_arn = "${aws_alb_target_group.nginx.arn}"
  }
}

# Set the alb target group.
resource "aws_alb_target_group" "nginx" {
  name = "nginx-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_vpc.threetier.id}"
  
  health_check {
    interval = 30
    path = "/"
    healthy_threshold = 3
    unhealthy_threshold = 3
  }
 
  tags = {
    Name = "nginx target group"
  }
}

# Set the alb_target_group_attachment
resource "aws_alb_target_group_attachment" "nginx" {
  count = length(aws_instance.web)
  target_group_arn = "${aws_alb_target_group.nginx.arn}"
  target_id = aws_instance.web[count.index].id
  port = 80
}

# Set the bastion host key pair
resource "aws_key_pair" "bastion_key" {
  key_name = "threetier_bastion_key"
  public_key = "${file("${var.key_pair_path["public_key_path"]}")}"
}

# Create the bastion instance
resource "aws_instance" "bastion" {
  ami = "ami-0c5a717974f63b04c"
  key_name = "${aws_key_pair.bastion_key.key_name}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}", 
                            "${aws_security_group.threetier_default.id}",
                           ]
  subnet_id = "${aws_subnet.threetier_dmz_subnet.0.id}"
  associate_public_ip_address = true
  
  tags = {
    Name = "Bastion HOST for access to private ec2"
  }
}

# Create the two web(nginx) instance 
resource "aws_instance" "web" {
  count = "${length(var.availability_zone)}"
  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${self.private_ip}"
    private_key =  "${file("${var.key_pair_path["private_key_path"]}")}"
    
    bastion_host = "${aws_instance.bastion.public_ip}"
    bastion_user = "ubuntu"
    bastion_private_key = "${file("${var.key_pair_path["private_key_path"]}")}"
  }
  key_name = "${aws_key_pair.bastion_key.key_name}" 
  instance_type = "t2.micro"
  ami = "ami-0c5a717974f63b04c"
  vpc_security_group_ids = [ "${aws_security_group.threetier_default.id}"
                           ]
  subnet_id = "${element(aws_subnet.threetier_web_subnet.*.id, count.index)}"
  provisioner "file" {
    source = "script.sh"
    destination = "$HOME/script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/script.sh",
      "sudo $HOME/script.sh"
    ]
  }
  
  tags = {
    Name = "nginx-${count.index+1}"
  }
  depends_on = ["aws_nat_gateway.threetier"]
}
