terraform {
  backend "local" {
    path = "/data/terraform.tfstate"
  }
}

provider "aws" {
  version = "~> 2.52"
}

provider "local" {
  version = "~> 1.4"
}
