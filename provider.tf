provider "aws" {
  shared_credentials_file = "/Users/glenyu/.aws/credentials"
  profile                 = "ampledev"
}

provider "template" {}
