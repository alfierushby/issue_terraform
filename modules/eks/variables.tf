variable intra_subnet_ids{
    description = "Subnet ids for the intra subnets."
    type = list(string)
}

variable private_subnet_ids{
    description = "Subnet ids for the private subnets."
    type = list(string)
}

variable public_subnet_ids{
    description = "Subnet ids for the public subnets."
    type = list(string)
}

variable vpc_id{
    description = "VPC id for main vpc"
    type = string
}

variable cluster_name{
    description = "Cluster name of EKS cluster"
    type = string
    default = "issue_creator_eks_cluster"
}