# Create an IAM role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
    description = "ECS Task Execution Role for ECS Tasks"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
        Project = var.project_name
        Environment = var.environment
        Service = "Nginx"
        Terraform = "true"
    }
}


# Attach necessary policies to the ECS Task Execution Role
locals {
    ecs_task_execution_policies = [
        "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    ]
}


# Attach each policy in the list to the role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
    for_each = toset(local.ecs_task_execution_policies)
    role = aws_iam_role.ecs_task_execution_role.name
    policy_arn = each.value
}
