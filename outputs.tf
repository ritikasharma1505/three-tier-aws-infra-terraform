output "region" {
  value = var.region
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.db.endpoint
}

output "acm_validation_records" {
  value = aws_acm_certificate.cert.domain_validation_options
}



