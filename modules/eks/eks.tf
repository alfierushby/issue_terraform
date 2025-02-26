module "eks"{
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20.31"

    cluster_name    = var.cluster_name
    cluster_version = "1.31"

    subnet_ids = var.private_subnet_ids
    control_plane_subnet_ids = var.intra_subnet_ids

    vpc_id = var.vpc_id

    
}