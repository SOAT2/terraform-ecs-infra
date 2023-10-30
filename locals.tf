locals {
  public_subnet_cidrs = ["10.0.32.0/20", "10.0.48.0/20", "10.0.64.0/20"]

  ecr_repo_name = "order-ecr"

  order_cluster_name = "order-cluster"
  // ecr_repo_url  = "882732830129.dkr.ecr.us-east-1.amazonaws.com/apieventos"
  availability_zones           = ["us-east-1c", "us-east-1d", "us-east-1e"]
  order_task_famliy            = "order-task"
  container_port               = 3000
  order_task_name              = "order-task"
  ecs_task_execution_role_name = "order-task-execution-role"

  application_load_balancer_name = "order-alb"
  target_group_name              = "demo-alb-tg"

  order_service_name = "order-service"
}