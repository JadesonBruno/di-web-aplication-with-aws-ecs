# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
    name = "${var.project_name}-${var.environment}-cluster"

    tags = {
        Name = "${var.project_name}-${var.environment}-cluster"
        Project = "${var.project_name}"
        Environment = "${var.environment}"
        Service = "Nginx"
        Terraform = "true"
    }
}


# CloudWatch Log Group for ECS Tasks
resource "aws_cloudwatch_log_group" "ecs_log_group" {
    name = "/aws/ecs/${var.project_name}-${var.environment}-task-definition"

    retention_in_days = 7

    tags = {
        Name = "aws/ecs/${var.project_name}-${var.environment}-task-definition"
        Project = "${var.project_name}"
        Environment = "${var.environment}"
        Service = "Nginx"
        Terraform = "true"
  }
}


resource "aws_ecs_task_definition" "ecs_task" {
    family = "${var.project_name}-${var.environment}-task-definition"

    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    cpu = var.cpu
    memory = var.memory
    task_role_arn = aws_iam_role.ecs_task_execution_role.arn
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture = "X86_64"
    }

    container_definitions = jsonencode([
        {
            name = "nginx",
            image = var.docker_image,
            essential = true,
            portMappings = [
                {
                    containerPort = var.container_port
                    hostPort = var.host_port
                    protocol = "tcp"
                    appProtocol = "http"
                }
            ],

            environment_files = [
                {
                    value = var.env_vars_bucket_arn
                    type = "s3"
                }
            ],

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-create-group = "true"
                    awslogs-group = aws_cloudwatch_log_group.ecs_log_group.name
                    awslogs-region = var.aws_region
                    awslogs-stream-prefix = "ecs"
                }
            }
        }
    ])
}


resource "aws_alb" "ecs_alb" {
    name = "${var.project_name}-${var.environment}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = var.public_subnet_ids

    tags = {
        Name = "${var.project_name}-${var.environment}-alb"
        Project = "${var.project_name}"
        Environment = "${var.environment}"
        Service = "Nginx"
        Terraform = "true"
    }
}


# ALB Target Group
resource "aws_lb_target_group" "ecs_target_group" {
    name = "${var.project_name}-${var.environment}-tg"
    port = var.container_port
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc_id

    health_check {
        path = var.health_check_path
        protocol = "HTTP"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
        matcher = "200-299"
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-tg"
        Project = "${var.project_name}"
        Environment = "${var.environment}"
        Service = "Nginx"
        Terraform = "true"
    }
}


# ALB Listener
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_alb.ecs_alb.arn
    port = var.alb_port
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.ecs_target_group.arn
    }
}


# ECS Service
resource "aws_ecs_service" "ecs_service" {
    name = "${var.project_name}-${var.environment}-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.ecs_task.arn
    desired_count = var.desired_count

    launch_type = "FARGATE"

    network_configuration {
        subnets = var.public_subnet_ids
        security_groups = [aws_security_group.ecs_service_sg.id]
        assign_public_ip = true
    }

    health_check_grace_period_seconds = 60

    load_balancer {
        target_group_arn = aws_lb_target_group.ecs_target_group.arn
        container_name = "nginx"
        container_port = var.container_port
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-service"
        Project = "${var.project_name}"
        Environment = "${var.environment}"
        Service = "Nginx"
        Terraform = "true"
    }
}
