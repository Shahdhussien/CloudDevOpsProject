module "network" {
  source                  = "./modules/network"
  vpc_cidr                = "10.0.0.0/16"
  public_subnet_cidr      = "10.0.1.0/24"
  private_subnet_cidr     = "10.0.2.0/24"
  region                  = "us-east-1"
  availability_zone       = "us-east-1a"
  private_availability_zone = "us-east-1b"
}

module "server" {
  source            = "./modules/server"
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_id
  ami_id            = var.ami_id
  key_name          = var.key_name
  env               = var.env
}

# module "eks" {
#   source        = "./modules/eks"
# #   version = "20.8.4"
#   region        = var.region
#   cluster_name  = "dev-eks-cluster"
#   subnet_ids    = module.network.public_subnet_id
#   vpc_id        = module.network.vpc_id
# }


terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-shahd"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}



