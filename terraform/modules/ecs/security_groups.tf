# ALB Security Group
resource "aws_security_group" "alb_sg" {
    name_prefix = "${var.project_name}-${var.environment}-alb-sg-"
    description = "SG to ALB"
    vpc_id = var.vpc_id

    ingress {
        description = "Allow HTTP traffic from the internet"
        from_port = var.alb_port
        to_port = var.alb_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "All outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
        create_before_destroy = true
    }
}


# ECS Service Security Group
resource "aws_security_group" "ecs_service_sg" {
    name_prefix = "${var.project_name}-${var.environment}-ecs-service-sg-"
    description = "SG to ECS Service"
    vpc_id = var.vpc_id

    ingress {
        description = "Allow traffic to Nginx container"
        from_port = var.container_port
        to_port = var.container_port
        protocol = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    egress {
        description = "All outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-ecs-service-sg"
        Project = var.project_name
        Environment = var.environment
        Service = "Nginx"
        Terraform = "true"
    }

    lifecycle {
      create_before_destroy = true
    }
}
