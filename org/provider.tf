provider "aws" {
  alias  = "aws"
  region = "us-east-1"

  shared_credentials_files = ["../.aws/credentials"]

  default_tags {
    tags = {
      author     = "Grupo 6"
      version    = 1
      university = "ITBA"
      subject    = "Cloud Computing"
      created-by = "terraform"
    }
  }
}