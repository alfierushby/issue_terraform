data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "dns" {
  statement {
    actions   = ["route53:ListHostedZones"]
    resources = ["arn:aws:route53:::hostedzone/*"]
    effect = "Allow"
  }
  statement {
    actions   = ["route53:ListHostedZones","route53:ChangeResourceRecordSets","route53:ListResourceRecordSets"]
    resources = ["*"]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "ebs_csi" {
  statement {
    actions   = ["ec2:CreateVolume","ec2:DeleteVolume","ec2:AttachVolume","ec2:DetachVolume","ec2:DescribeVolumes"]
    resources = ["*"]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "ecr" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
    effect = "Allow"
  }
   statement {
    actions   = ["ecr:BatchCheckLayerAvailability","ecr:GetDownloadUrlForLayer","ecr:BatchGetImage"]
    resources = ["arn:aws:ecr:region:${data.aws_caller_identity.current.account_id}:repository/*"]
    effect = "Allow"
  }
}


resource "aws_iam_policy" "dns" {
  name        = "External-DNS"
  description = " Grants Route 53 permissions for managing DNS records."
  policy = data.aws_iam_policy_document.dns.json
}

resource "aws_iam_policy" "ebs_csi" {
  name        = "EBS-CSI-Driver"
  description = "     Allows managing EBS storage for EKS. "
  policy = data.aws_iam_policy_document.ebs_csi.json
}

resource "aws_iam_policy" "ecr" {
  name        = "ECR-Access"
  description = "Grants permissions to pull container images from AWS ECR."
  policy = data.aws_iam_policy_document.ecr.json
}


# module "iam_eks_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
#   version = "5.52.2"
#   role_name = "role_eks"

#   cluster_service_accounts = {
#     "cluster1" = ["kube_system:serviceaccount:alfie:role_eks"]
#   }

#    role_policy_arns = {
#     AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   }
# }

# module "iam_eks_role_lb" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
#   version = "5.52.2"
#   role_name = "iam_eks_role_lb_controller"

#   cluster_service_accounts = {
#     "cluster1" = ["kube_system:serviceaccount:alfie:load_balancer_controller"]
#   }

#    role_policy_arns = {
#     AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
#   }
# }


# module "iam_eks_role_external_dns" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
#   version = "5.52.2"
#   role_name = "external_dns"

#   cluster_service_accounts = {
#     "cluster1" = ["kube_system:serviceaccount:alfie:external_dns"]
#   }

#    role_policy_arns = {
#     AmazonEKS_CNI_Policy = aws_iam_policy.dns.arn
#   }
# }

# module "iam_eks_role_ebs_csi" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
#   version = "5.52.2"
#   role_name = "ebs_csi_role"

#   cluster_service_accounts = {
#     "cluster1" = ["kube_system:serviceaccount:alfie:csi_ebs"]
#   }

#    role_policy_arns = {
#     AmazonEKS_CNI_Policy = aws_iam_policy.ebs_csi.arn
#   }
# }

# module "iam_eks_role_sqs" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
#   version = "5.52.2"
#   role_name = "sqs_role"

#   cluster_service_accounts = {
#     "cluster1" = ["kube_system:serviceaccount:alfie:sqs"]
#   }

#    role_policy_arns = {
#     AmazonEKS_CNI_Policy = var.sqs_policy_arn
#   }
# }
