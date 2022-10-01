resource "aws_ecr_repository" "this" {
  name                 = lower(var.name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key = var.kms_arn
  }

  force_delete = !var.protected
}