provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source = "./modules/vpc"
  # version = "1.0.0" # Replace with your module version
}

module "iam" {
  source = "./modules/iam"
  # version = "1.0.0" # Replace with your module version
}

module "eks" {
  source              = "./modules/eks"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.subnet_ids
  cluster_role_arn    = module.iam.cluster_role_arn
  node_group_role_arn = module.iam.node_group_role_arn
  ssh_key_name        = var.ssh_key_name
  depends_on          = [module.iam] # Explicit dependency on IAM module Explanation: This ensures the IAM roles are created before the EKS cluster.

}