resource "aws_route53_zone" "example_zone" {
  name = "example.com"
}

resource "aws_route53_record" "example_record" {
  zone_id = aws_route53_zone.example_zone.id
  name    = "example.com"
  type    = "A"

  alias {
    name                   = aws_elb.example_elb.dns_name
    zone_id                = aws_elb.example_elb.zone_id
    evaluate_target_health = true
  }
}
