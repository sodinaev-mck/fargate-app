data "aws_kms_key" "ecr" {
  key_id = "alias/aws/ecr"
}

locals {
  app_name = join("-", [var.ns, var.app])
}

module "container_registry" {
  source  = "./modules/ecr"
  name    = local.app_name
  kms_arn = data.aws_kms_key.ecr.arn
}

module "lb" {
  source   = "./modules/lb"
  app_name = local.app_name
  subnets  = var.private_subnets
}

module "fargate-cluster" {
  source       = "./modules/ecs-fargate"
  app_name     = local.app_name
  subnets      = var.private_subnets
  registry_url = module.container_registry.repo_url
  lb_sg_id     = module.lb.lb_sg_id
  lb_target_id = module.lb.lb_target_id
}
