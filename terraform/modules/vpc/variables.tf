variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "vpc_name" {
  type    = string
  default = "expdevops-vpc"
}

variable "subnet_name" {
  type    = string
  default = "expdevops-subnet"
}

variable "igw_name" {
  type    = string
  default = "expdevops-igw"
}

variable "route_table_name" {
  type    = string
  default = "expdevops-route-table"
}