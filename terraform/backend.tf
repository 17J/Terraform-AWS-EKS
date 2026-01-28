terraform {
  backend "s3" {
    bucket         = "my-eks-terraform-state-rah"    # Replace With Your Bucket Name
    key            = "eks-cluster.tfstate"
    region         = "ap-south-1"                   # Replace With Your Region Name
    dynamodb_table = "terraform-locks"              # Replace With Your Dynamodb Table Name
    encrypt        = true
  }
}