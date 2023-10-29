resource "aws_ecr_repository" "order_ecr_repository" {
  name = var.ecr_repo_name
}
