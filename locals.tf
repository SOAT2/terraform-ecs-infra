locals {
  bucket_name = "order-tf"
  table_name  = "orderTF"

  ecr_repo_name = "order-ecr"

  order_cluster_name           = "order-cluster"
  availability_zones           = ["us-east-1a", "us-east-1b", "us-east-1c"]
  order_task_famliy            = "order-task"
  container_port               = 3000
  order_task_name              = "order-task"
  ecs_task_execution_role_name = "order-task-execution-role"

  application_load_balancer_name = "order-alb"
  target_group_name              = "demo-alb-tg"

  order_service_name = "order-service"
}