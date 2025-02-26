output intra_subnet_ids{
    description = "Subnet ids for the intra subnets."
    value = local.intra_subnets
}

output private_subnet_ids{
    description = "Subnet ids for the private subnets."
    value = local.private_subnets
}

output public_subnet_ids{
    description = "Subnet ids for the public subnets."
    value = local.public_subnets
}

output vpc_id{
    description = "ID of the VPC"
    value = module.vpc.vpc_id
}
