data "aws_caller_identity" "current" {}

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

data "aws_iam_policy_document" "bedrock_invoke" {
  statement {
    actions   = ["bedrock:InvokeModel","bedrock:InvokeModelWithResponseStream", "bedrock:CreateModelInvocationJob"]
    resources = ["arn:aws:bedrock:*::foundation-model/amazon.titan-text-express-v1"]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "ses_email" {
  statement {
    actions   = ["ses:SendEmail","ses:SendRawEmail","ses:SendTemplatedEmail"]
    resources = ["*"]
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

resource "aws_iam_policy" "ecr" {
  name        = "Alfie-ECR-Access"
  description = "Grants permissions to pull container images from AWS ECR."
  policy = data.aws_iam_policy_document.ecr.json
}


resource "aws_iam_policy" "sqs_read" {
  name        = "Alfie-SQS-Write-Access"
  description = "Grants read access to SQS queues."
  policy = data.aws_iam_policy_document.sqs_read.json
}


resource "aws_iam_policy" "ses_email" {
  name        = "Alfie-SES-Email-Access"
  description = "Grants email access to SES."
  policy = data.aws_iam_policy_document.ses_email.json
}

resource "aws_iam_policy" "bedrock_invoke" {
  name        = "Alfie-Bedrock-Invoke"
  description = "Grants bedrock invoke access."
  policy = data.aws_iam_policy_document.bedrock_invoke.json
}

resource "aws_iam_policy" "sqs_write" {
  name        = "Alfie-SQS-Read-Access"
  description = "Grants write access to SQS queues."
  policy = data.aws_iam_policy_document.sqs_write.json
}


module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "alfie-role_eks"

  role_policy_arns = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["alfie:role-eks"]
    }
  }
} 


module "iam_eks_role_lb" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "alfie-iam_eks_role_lb_controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

module "iam_eks_role_external_dns" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "alfie-external_dns"

  attach_external_dns_policy = true
  

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-external-dns-csi"]
    }
  }
}

module "iam_eks_role_ebs_csi" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "alfie-ebs_csi_role"

  attach_ebs_csi_policy=true

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["alfie:ebs-csi"]
    }
  }
}


module "iam_eks_role_ses_sqs_read" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "alfie-sqs_read_sqs_email"

  role_policy_arns = {
    SQS_READ_POLICY = aws_iam_policy.sqs_read.arn,
    SES_WRITE_POLICY = aws_iam_policy.ses_email.arn,
    BEDROCK_POLICY = aws_iam_policy.bedrock_invoke.arn,
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["alfie:sqs-read-sqs-email"]
    }
  }
}


module "iam_eks_role_sqs_read" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "alfie-sqs_role_read"

  role_policy_arns = {
    SQS_READ_POLICY = aws_iam_policy.sqs_read.arn,
    BEDROCK_POLICY = aws_iam_policy.bedrock_invoke.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["alfie:sqs-read"]
    }
  }
}

module "iam_eks_role_sqs_write" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "alfie-sqs_role_write"

  role_policy_arns = {
    AmazonEKS_CNI_Policy = aws_iam_policy.sqs_write.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["alfie:sqs-write"]
    }
  }
}