terraform {
  backend "s3" {
    bucket = "sctp-ce6-tfstate"
    key    = "ven-ecs-dev.tfstate"   # Hardcoded key for dev environment
    region = "ap-southeast-1"
  }
}