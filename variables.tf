variable "aws_region" {
  description = "The AWS region to be used"
  default = "eu-west-1"
}

variable "name" {
    description = "name and tag of the deployment"
}

variable "ami" {
    description = "The AMI to be used"
    default = "ami-0c1f3a8058fde8814"
}

variable "key_name" {
    description = "name of the ssh key to be used"
}

variable "network_address_space" {
  description = "The default CIDR to use"
  default     = "172.16.0.0/16"
}

variable "instance_type" {
  description = "Type of EC2 cluster instance"
  default     = "t2.small"
}


variable "root_block_device_size" {
  default = "80"
}

variable "whitelist_ip" {
  description = "The allowed ingress IP CIDR assigned to the ASGs"
  default     = "0.0.0.0/0"
}