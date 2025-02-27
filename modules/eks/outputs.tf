output cluster_name{
    description = "Cluster name of EKS cluster"
    value = module.eks.cluster_name
}

output node_group_settings{
    value = var.node_group_settings
}

output oidc_provider_arn{
    value = module.eks.oidc_provider_arn
}