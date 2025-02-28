
module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20.31"

    cluster_name    = var.cluster_name
    cluster_version = "1.32"

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

    eks_managed_node_groups = {
        for index,v in var.node_group_settings: "node${index}" => {
            ami_type       = "AL2023_x86_64_STANDARD"
            instance_types = [v.instance_type]
            subnet_ids = [var.private_subnet_ids[index]]

            min_size     = v.min_size
            max_size     = v.max_size
            desired_size = v.desired_size

            iam_role_additional_policies = {
               policy1= "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
               policy2= var.ecr_read_policy_arn
            }

            launch_template = {
                root_volume_type = "gp3"
                root_volume_size = 20
            }           

            tags = {
                "Name" = "${var.cluster_name}-node${index}"
            }

            labels = {
                "managed-by" = "terraform"
                "k8s-app" = "alfie-app-issue-reporter"
            }
        }
    }
}