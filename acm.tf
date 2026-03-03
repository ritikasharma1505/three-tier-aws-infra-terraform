resource "aws_acm_certificate" "cert" {
  domain_name       = "cloudeploy.in"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "cloudeploy-cert"
  }
}