variable "profile" {
  description = "The AWS profile used"
  default = "default"
}

variable "service_name" {
  description = "The service name"
  #default = "jenkinsdockerv1"
}

variable "ec2_instance_type" {
  description = "EC2 Instance Type"
  #default = "t2.micro"
}

variable "num_nodes" {
  description = "Number of nodes in the autoscaling group"
  default = "1"
}

variable "max_num_nodes" {
  description = "Max number of nodes in the autoscaling group"
  default = "1"
}

variable "min_num_nodes" {
  description = "Min of nodes in the autoscaling group"
  default = "1"
}


variable "ami_id" {
  description = "EC2 Image Id"

}

variable "ec2_keypair_name" {
  description = "SSH Keypair Name"
}

variable "environment_prefix" {
  description = "The environment identifier e.g. engineering,prod,green,blue"
  #default ="jenkins"
}

variable "environment" {
  description = "The environment TYPE"
  #default = "dev"
}


variable "aws_region" {
  description = "The primary region (to orchestrate things which happen once)"
  #default =  "us-west-2"
}

variable "route53_zone_base" {
  description = "Route 53 Zone Name"
  #default = "devops.xxxxx.io"
}

variable "vpc_name" {
  description = "VPC Name to be search by data resource"
}

variable "jenkins_v1_role_prefix"
{
  description = "Jenkins Role Name Prefix"
  default = "jenkins_v1_role"
}

variable "availibity_zone_suffix"
{
  description = "availibity zone suffix"
}
variable "aws_profile"
{
  description = "aws_profile"
}

