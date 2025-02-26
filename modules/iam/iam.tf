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

data "aws_iam_policy_document" "sqs" {
  statement {
    actions   = ["sqs:ListQueues"]
    resources = ["*"]
    effect = "Allow"
  }
   statement {
    actions   = ["sqs:SendMessage","sqs:ReceiveMessage","sqs:DeleteMessage"]
    resources = ["arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:*"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "dns" {
  name        = "External-DNS"
  description = " Grants Route 53 permissions for managing DNS records."
  policy = data.aws_iam_policy_document.dns.json
}

resource "aws_iam_policy" "ebs" {
  name        = "EBS-CSI-Driver"
  description = "     Allows managing EBS storage for EKS. "
  policy = data.aws_iam_policy_document.ebs_csi.json
}

resource "aws_iam_policy" "ecr" {
  name        = "ECR-Access"
  description = "Grants permissions to pull container images from AWS ECR."
  policy = data.aws_iam_policy_document.ecr.json
}


resource "aws_iam_policy" "sqs" {
  name        = "SQS-Access"
  description = "Grants access to SQS queues."
  policy = data.aws_iam_policy_document.sqs.json
}

