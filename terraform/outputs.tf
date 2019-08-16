output "alb_dns_name" {
  value = "${aws_lb.lb.dns_name}"
}

output "elb_dns_name" {
  value = "${aws_elb.gw-elb.dns_name}"
}

output "hostnames" {
  value       = "${aws_route53_record.aqua-console.*.fqdn}"
  description = "List of DNS records"
}
