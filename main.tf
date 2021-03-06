terraform {
  backend "s3" {
    bucket         = "terraform-state-frankyvenus"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-southeast-2"
    profile        = "default"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"
  profile = "default"
}

#
# =======================
# SECTION: Other modules
# =======================
#

module "statebackend" {
  source = "git@github.com:franky-devOps/terraform-s3-backend-module.git"

  bucket_name   = "jubbiepizza-tf-state-bucket"
  table_name    = "jubbiepizza-tf-state-locking"
  kms_key_alias = "alias/jubbiepizza/tf-state-key"
}

module "acm-certificate" {
  source = "./acm-certificate"

  aws_acm_certificate_domain_name      = "file-manager.jubbiepizza.com"
  aws_acm_certificate_additional_names = ["www.file-manager.jubbiepizza.com"]
  hosted_zone_name                     = "jubbiepizza.com"
}
