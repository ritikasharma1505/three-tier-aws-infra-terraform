
# -------- Public Hosted Zone ------------
data "aws_route53_zone" "selected" {
  name         = "cloudeploy.in"
  private_zone = false
}

# -------- Create "A" record --------------
resource "aws_route53_record" "alb_alias" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "cloudeploy.in"
  type    = "A"

  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}