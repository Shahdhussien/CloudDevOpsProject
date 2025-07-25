# provider "aws" {
#   region = var.region
# }

# module "eks" {
#   source          = "terraform-aws-modules/eks/aws"
#   version         = "20.8.4"

#   cluster_name    = var.cluster_name
#   cluster_version = "1.29"
#   subnet_ids      = var.subnet_ids
#   vpc_id          = var.vpc_id

#   eks_managed_node_groups = {
#     default = {
#       desired_capacity = 2
#       max_capacity     = 3
#       min_capacity     = 1

#       instance_types = ["t3.medium"]
#       tags = {
#         Name = "eks-node"
#       }
#     }
#   }

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }
