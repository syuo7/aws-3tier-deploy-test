output "aws_alb_address" {
  description = "This address is dns name of the ALB"
  value = "${aws_alb.alb.dns_name}"
}
