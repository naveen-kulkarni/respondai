resource "aws_route53_zone" "example" {
  name     = "example.com"
  
  private_zone = false
}

resource "aws_route53_record" "linux-alb-a-record" {
  depends_on = [aws_lb.linux-alb]
  zone_id = data.aws_route53_zone.public-zone.zone_id
  name    = "${var.dns_hostname}.${var.public_dns_name}"
  type    = "A"
  alias {
    name                   = aws_lb.linux-alb.dns_name
    zone_id                = aws_lb.linux-alb.zone_id
    evaluate_target_health = true
  }
}
