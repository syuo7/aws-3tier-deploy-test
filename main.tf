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

# Create the EIP
resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = ["aws_internet_gateway.gw"]
}

# Create for the elb
resource "aws_elb" "elb" {
  name = "elb"
  
  subnets = "${aws_subnet.threetier_dmz_subnet.*.id}"
  security_groups = ["${aws_security_group.elb.id}",
                   #  "${aws_security_group.threetier_default.id}"
                    ]
  instances = "${aws_instance.web.*.id}"

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
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
  associate_public_ip_address = true
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
}
