# VPC Module
module "vpc" {
    source = "./modules/vpc"
    project_name = var.project_name
    environment = var.environment
    aws_region = var.aws_region
    vpc_cidr_block = var.vpc_cidr_block
}


# Environment Variables S3 Bucket Module
module "env_vars_bucket" {
    source = "./modules/env_vars_bucket"
    project_name = var.project_name
    environment = var.environment
}


# ECS Module
module "ecs" {
    source = "./modules/ecs"
    project_name = var.project_name
    environment  = var.environment
    cpu = var.cpu
    memory = var.memory
    docker_image = var.docker_image
    container_port = var.container_port
    host_port = var.host_port
    alb_port = var.alb_port
    env_vars_bucket_arn = module.env_vars_bucket.env_vars_bucket_arn
    vpc_id = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnet_ids
    health_check_path = var.health_check_path
    desired_count = var.desired_count
}
