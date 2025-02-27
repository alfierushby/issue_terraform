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

data "aws_iam_policy_document" "sqs_read" {
  statement {
    actions   = ["sqs:ListQueues"]
    resources = ["*"]
    effect = "Allow"
  }
   statement {
    actions   = ["sqs:SendMessage","sqs:ReceiveMessage","sqs:DeleteMessage","sqs:GetQueueAttributes"]
    resources = var.sqs_queue_arns
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "sqs_write" {
  statement {
    actions   = ["sqs:ListQueues"]
    resources = ["*"]
    effect = "Allow"
  }
   statement {
    actions   = ["sqs:SendMessage","sqs:GetQueueAttributes"]
    resources = var.sqs_queue_arns
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


resource "aws_iam_policy" "sqs_read" {
  name        = "SQS-Access"
  description = "Grants read access to SQS queues."
  policy = data.aws_iam_policy_document.sqs_read.json
}


resource "aws_iam_policy" "sqs_write" {
  name        = "SQS-Access"
  description = "Grants write access to SQS queues."
  policy = data.aws_iam_policy_document.sqs_write.json
}

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "role_eks"

  role_policy_arns = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube_system:serviceaccount:alfie:role_eks"]
    }
  }
} 

module "iam_eks_role_lb" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "iam_eks_role_lb_controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube_system:serviceaccount:alfie:ebs_external_dns_csi"]
    }
  }
}

module "iam_eks_role_external_dns" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "external_dns"

  role_policy_arns = {
    AmazonEKS_CNI_Policy = aws_iam_policy.dns.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube_system:serviceaccount:alfie:ebsexternal_dns_csi"]
    }
  }
}

module "iam_eks_role_ebs_csi" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "ebs_csi_role"

  role_policy_arns = {
    AmazonEKS_CNI_Policy = aws_iam_policy.ebs_csi.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube_system:serviceaccount:alfie:ebs_csi"]
    }
  }
}

module "iam_eks_role_sqs_read" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "sqs_role_read"

  role_policy_arns = {
    AmazonEKS_CNI_Policy = aws_iam_policy.sqs_read.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube_system:serviceaccount:alfie:sqs_read"]
    }
  }
}

module "iam_eks_role_sqs_write" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "sqs_role_write"

  role_policy_arns = {
    AmazonEKS_CNI_Policy = aws_iam_policy.sqs_write.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube_system:serviceaccount:alfie:sqs_write"]
    }
  }
}