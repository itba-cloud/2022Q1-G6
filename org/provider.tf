provider "aws" {
  alias  = "aws"
  region = "us-east-1"

  shared_credentials_files = ["../.aws/credentials"]

  default_tags {
    tags = {
      Owner       = "Grupo 6"
      Version     = 1
      University  = "ITBA"
      Project     = "Cloud Computing"
      Created-By  = "terraform"
      Environment = "dev"
    }
  }
}