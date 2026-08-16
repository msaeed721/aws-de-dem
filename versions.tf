terraform {
  required_version = ">= 1.13.0"

  backend "s3" {
    bucket       = "aws-de-demo-tfstate-029633610686"
    key          = "dev/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}