output intra_subnet_ids{
    description = "Subnet ids for the intra subnets."
    value = module.vpc.intra_subnets
}

output private_subnet_ids{
    description = "Subnet ids for the private subnets."
    value = module.vpc.private_subnets
}

output public_subnet_ids{
    description = "Subnet ids for the public subnets."
    value = module.vpc.public_subnets
}

output vpc_id{
    description = "ID of the VPC"
    value = module.vpc.vpc_id
}