variable "aws_access_key" {
    description = ""
    default = ""
}
variable "aws_secret_key" {
    description = ""
    default = ""
}
variable "aws_region" {
    description = ""
    default = "ap-northeast-2"
}
variable "vpc_cidr" {
  description = "CIDR for 3tier"
  default = "10.10.0.0/16"
}
variable "availability_zone" {
  description = "Seoul region availability zone"
  type = "list"
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}
