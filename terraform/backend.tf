# backend.tf
terraform {
  backend "s3" {
    bucket = "sctp-ce6-tfstate"  
    key    = "ven-ecs-${var.env}.tfstate"  
    region = "ap-southeast-1"  
  }
}