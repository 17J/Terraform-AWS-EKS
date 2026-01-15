variable "cluster_name" {
  type    = string
  default = "expdevops-cluster"
}

variable "cluster_role_arn" {
  type = string
}

variable "node_group_role_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ssh_key_name" {
  type    = string
  default = "devops"
}

variable "instance_types" {
  type    = list(string)
  default = ["t2.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 3
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_min_size" {
  type    = number
  default = 3
}

variable "node_ingress_cidrs" {
    type = list(string)
    default = ["0.0.0.0/0"] #CHANGE THIS TO A SPECIFIC IP RANGE FOR SECURITY
    # SUGGESTION: Replace "0.0.0.0/0" with specific IP ranges or security groups.
}
