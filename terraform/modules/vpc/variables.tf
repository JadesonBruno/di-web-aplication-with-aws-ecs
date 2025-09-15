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