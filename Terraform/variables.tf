variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "ami_id" {
  default = "ami-08a6efd148b1f7504" 
}

variable "key_name" {
  default = "jenkins-key"
}

variable "env" {
  default = "dev"
}
