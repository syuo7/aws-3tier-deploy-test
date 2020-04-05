output "address" {
  value = "${aws_elb.elb.dns_name}"
}
