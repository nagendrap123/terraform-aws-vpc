### vpc ###
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}
variable "enable_dns_hostnames" {
    type = bool
    default = "true"
  
}
variable "tags" {
    default = {}  #empty tags 
  
}

## project ###
variable "project_name" {
    type = string
  
}

variable "environment" {
    type = string
    default = "dev"
  
}

variable "common_tags" {
    type = map 
  
}

###igw ####
variable "igw_tags" {
 type = map 
 default = {}  
}

###subnets###
variable "public_subnet_cidrs" {
    type =list 
    validation {
      condition = length(var.public_subnet_cidrs) == 2
      error_message = "please provide exact 2 public CIDRs values"
    }
  
}
variable "public_subnet_cidrs_tags" {
    type = map 
    default = {}
  
}