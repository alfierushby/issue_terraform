output ebs_csi_role_arn{
    value = module.iam_eks_role_ebs_csi.iam_role_arn
}

output ecr_read_policy{
    value = aws_iam_policy.ecr.arn
}