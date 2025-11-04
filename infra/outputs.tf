output "elb_base_url" {
    description = "Elastic Load Balancer URL"
    value = aws_lb.n8n_alb.dns_name
}