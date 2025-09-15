output "alb_public_dns_name" {
    description = "The public DNS name of the ALB"
    value = aws_alb.ecs_alb.dns_name
}
