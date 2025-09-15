# Global Variables
variable "project_name" {
    description = "The name of the project"
    type = string
}

variable "environment" {
    description = "The deployment environment (e.g., dev, staging, prod)"
    type = string
    default = "dev"

    validation {
        condition = contains(["dev", "staging", "prod"], var.environment)
        error_message = "Environment must be one of 'dev', 'staging', or 'prod'."
    }
}

variable "aws_region" {
    description = "The AWS region to deploy resources in"
    type = string
    default = "us-east-2"
}


# VPC Module Variables
variable "vpc_cidr_block" {
    description = "The CIDR block for the VPC"
    type = string
    default = "10.1.0.0/16"
}


# ECS Module Variables
variable "cpu" {
    description = "The number of CPU units used by the task"
    type = string
    default = "1024"
}

variable "memory" {
    description = "The amount of memory (in MiB) used by the task"
    type = string
    default = "2048"
}

variable "docker_image" {
    description = "The Docker image to use for the ECS task"
    type = string
    default = "nginx:latest"
}

variable "container_port" {
    description = "The port on which the container listens"
    type = number
    default = 80
}

variable "host_port" {
    description = "The port on the host to which the container port is mapped"
    type = number
    default = 80
}

variable "alb_port" {
    description = "The port on which the ALB listens"
    type = number
    default = 80
}

variable "health_check_path" {
    description = "The HTTP path for the health check"
    type = string
    default = "/"
}

variable "desired_count" {
    description = "The desired number of ECS tasks to run"
    type = number
    default = 1
}
