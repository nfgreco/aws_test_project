
module "vpc-test-project" {
  source = "./module/aws-vpc"

  #aws_region  = "us-west-1"
  project     = "test-project"

  cidr_block     = "10.10.0.0/16"
  public_subnets = 2
  public_subnets_tags = {
    "Tier"                                  = "public"
  }
  private_subnets = 2
  private_subnets_tags = {
    "Tier"                                  = "private"
  }
}
