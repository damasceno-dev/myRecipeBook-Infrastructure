terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
  backend "s3" {
    bucket  = "myrecipebook-terraform-state-unique1029"  # Must match the bucket created in 1-admin
    key     = "3-apprunner/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


data "terraform_remote_state" "admin" {
  backend = "s3"
  config = {
    bucket = "myrecipebook-terraform-state-unique1029"
    key    = "1-admin/terraform.tfstate"
    region = "us-east-1"
  }
}
data "terraform_remote_state" "resources" {
  backend = "s3"
  config = {
    bucket = "myrecipebook-terraform-state-unique1029"
    key    = "2-resources/terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
  # for github actions or act (ci), its going to take the profile from the aws_id used in the credentials step. 
  # Use this if you want to run locally and have aws profiles configured in your machine 
  # profile = data.terraform_remote_state.resources.outputs.resources_creator_profile
}

module "app_runner" {
  source              = "./modules/app_runner"
  prefix             = data.terraform_remote_state.admin.outputs.prefix
  repository_arn = data.terraform_remote_state.resources.outputs.repository_arn
  repository_url = data.terraform_remote_state.resources.outputs.repository_url
}