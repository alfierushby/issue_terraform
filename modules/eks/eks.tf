module "eks"{
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20.31"

    cluster_name    = var.cluster_name
    cluster_version = "1.31"

    subnet_ids = var.private_subnet_ids
    control_plane_subnet_ids = var.intra_subnet_ids

    vpc_id = var.vpc_id

    authentication_mode = "API_AND_CONFIG_MAP"
    # Add full admin perm
    enable_cluster_creator_admin_permissions = true
    # Enable public access
    cluster_endpoint_public_access = true

    
    cluster_addons = {
        coredns                = {
            most_recent = true
        }
        kube-proxy             = {
            most_recent = true
        }
        vpc-cni                = {
            most_recent = true
        }
        aws-ebs-csi-driver     = {
            most_recent = true
            service_account_role_arn = var.ebs_csi_role_arn
        }
    }

}