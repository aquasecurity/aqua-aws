output "console_url" {
  value       = aws_route53_record.aqua-console.*.fqdn
  description = "List of DNS records"
}

output "gateway_url" {
  value = aws_alb.alb-gateway.dns_name
}

