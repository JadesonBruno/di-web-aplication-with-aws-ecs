output "alb_public_dns_name" {
    description = "The public DNS name of the ALB"
    value = module.ecs.alb_public_dns_name
}
