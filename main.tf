terraform {
  required_version = "~> 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# module "ecrRepo" {
#   source = "./modules/ecr"

#   ecr_repo_name = local.ecr_repo_name
# }

module "ecsCluster" {
  source = "./modules/ecs"

  order_cluster_name  = local.order_cluster_name
  availability_zones  = local.availability_zones
  public_subnet_cidrs = local.public_subnet_cidrs

  order_task_famliy            = local.order_task_famliy
  ecr_repo_url                 = local.ecr_repo_url
  container_port               = local.container_port
  order_task_name              = local.order_task_name
  ecs_task_execution_role_name = local.ecs_task_execution_role_name

  application_load_balancer_name = local.application_load_balancer_name
  target_group_name              = local.target_group_name
  order_service_name             = local.order_service_name
}
