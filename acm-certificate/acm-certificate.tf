variable "aws_acm_certificate_domain_name" {
  type = string
}
variable "aws_acm_certificate_additional_names" {
  type        = list(string)
  description = "Additional domain names that the aws certificate should cover"
}
variable "hosted_zone_name" {
  type        = string
  description = "The Route53 hosted zone that contain the records of that target domain, it is used for DNS validation"
}

resource "aws_acm_certificate" "cert" {
  domain_name               = var.aws_acm_certificate_domain_name
  subject_alternative_names = var.aws_acm_certificate_additional_names

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

// Add required records for DNS (domain name system) validation
resource "aws_route53_record" "records" {
  for_each = {
    for validationOption in aws_acm_certificate.cert.domain_validation_options : validationOption.domain_name => {
      name   = validationOption.resource_record_name
      record = validationOption.resource_record_value
      type   = validationOption.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

// Validate domain(s)
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.records : record.fqdn]
}
