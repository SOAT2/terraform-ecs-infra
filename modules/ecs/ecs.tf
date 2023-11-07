resource "aws_ecs_cluster" "order_cluster" {
  name = var.order_cluster_name
}

resource "aws_subnet" "orderPublicSubnet1" {
  vpc_id            = data.aws_vpc.order-soat-instance-vpc.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  map_public_ip_on_launch  = true
  tags = {
    Name    = "orderPublicSubnet1"
    Project = "Order TF"
  }
}

resource "aws_subnet" "orderPublicSubnet2" {
  vpc_id            = data.aws_vpc.order-soat-instance-vpc.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  map_public_ip_on_launch  = true
  tags = {
    Name    = "orderPublicSubnet2"
    Project = "Order TF"
  }
}

resource "aws_subnet" "orderPublicSubnet3" {
  vpc_id            = data.aws_vpc.order-soat-instance-vpc.id
  cidr_block        = var.public_subnet_cidrs[2]
  availability_zone = var.availability_zones[2]
  map_public_ip_on_launch  = true
  tags = {
    Name    = "orderPublicSubnet3"
    Project = "Order TF"
  }
}

resource "aws_ecs_task_definition" "order_task" {
  family                   = var.order_task_famliy
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.order_task_name}",
      "image": "${var.ecr_repo_url}:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port}
        }
      ],
      "memory": 2048,
      "cpu": 256,
      "environment": [
        {
          "name": "PORT",
          "value": "3000"
        },
        {
          "name": "POSTGRES_HOST",
          "value": "postgres"
        },
        {
          "name": "POSTGRES_PORT",
          "value": "5432"
        },
        {
          "name": "POSTGRES_DB",
          "value": "postgres"
        },
        {
          "name": "POSTGRES_PASSWORD",
          "value": "postgres"
        },
        {
          "name": "POSTGRES_USER",
          "value": "postgres"
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 2048
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_alb" "application_load_balancer" {
  name               = var.application_load_balancer_name
  load_balancer_type = "application"
  subnets = [
    "${aws_subnet.orderPublicSubnet1.id}",
    "${aws_subnet.orderPublicSubnet2.id}",
    "${aws_subnet.orderPublicSubnet3.id}"
  ]
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_security_group" "load_balancer_security_group" {
  name        = "security_group_lb"
  description = "Security Group LB"
  vpc_id            = data.aws_vpc.order-soat-instance-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "orderSecurityGroup"
    Project = "Order TF"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = var.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.order-soat-instance-vpc.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_ecs_service" "order_service" {
  name            = var.order_service_name
  cluster         = aws_ecs_cluster.order_cluster.id
  task_definition = aws_ecs_task_definition.order_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = var.order_task_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = ["${aws_subnet.orderPublicSubnet1.id}", "${aws_subnet.orderPublicSubnet2.id}", "${aws_subnet.orderPublicSubnet3.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
}

resource "aws_security_group" "service_security_group" {
  vpc_id            = data.aws_vpc.order-soat-instance-vpc.id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
