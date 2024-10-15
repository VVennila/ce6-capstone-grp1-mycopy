 terraform {
   backend "s3" {
    bucket = "sctp-ce6-tfstate"
    key    = "ven-ecs-ce6.tfstate"
    region = "ap-southeast-1"
   }
 }