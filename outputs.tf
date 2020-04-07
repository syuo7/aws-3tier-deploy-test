output "aws_elb_address" {
  description = "This address is dns name of the ELB"
  value = "${aws_elb.elb.dns_name}"
}
