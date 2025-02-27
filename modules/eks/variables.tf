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

variable ebs_csi_role_arn{
    description = "ARN for the EBS CSI role to give access to EBS in AWS"
    type = string
}

variable node_group_settings{
    description = "Sets instance type and capacity configurations"
    type = list(object({
        instance_type = optional(string,"t2.micro")
        min_size = optional(number,1)
        max_size = optional(number,2)
        desired_size = optional(number,1)
    }))
    default = [{},{},{}]
}

variable ecr_read_policy_arn{
    description = "The ARN of the ECR read policy"
    type = string
}

variable namespace_name{
    description = "Name of namespace"
    type = string
    default = "kube-system"
}