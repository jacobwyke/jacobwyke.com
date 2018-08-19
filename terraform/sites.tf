data "aws_iam_policy_document" "no_www_policy" {
	statement {
		actions   = ["s3:GetObject"]
		resources = ["${aws_s3_bucket.no_www.arn}/*"]

		principals {
			type        = "AWS"
			identifiers = ["*"]
		}
	}

}

data "aws_iam_policy_document" "www_policy" {
	statement {
		actions   = ["s3:GetObject"]
		resources = ["${aws_s3_bucket.www.arn}/*"]

		principals {
			type        = "AWS"
			identifiers = ["*"]
		}
	}
}

data "aws_iam_policy_document" "assets_policy" {
	statement {
		actions   = ["s3:GetObject"]
		resources = ["${aws_s3_bucket.assets.arn}/*"]

		principals {
			type        = "AWS"
			identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
		}
	}
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# S3 Buckets
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "aws_s3_bucket" "no_www" {
	bucket	= "${local.dashed_domain_name}"

	website {
		index_document = "index.html"
		error_document = "error.html"
	}
}

resource "aws_s3_bucket" "www" {
	bucket	= "www-${local.dashed_domain_name}"

	website {
    		redirect_all_requests_to = "https://${var.domain_name}"
	}
}

resource "aws_s3_bucket" "assets" {
	bucket	= "assets-${local.dashed_domain_name}"

}

resource "aws_s3_bucket_policy" "no_www" {
	bucket = "${aws_s3_bucket.no_www.id}"
	policy = "${data.aws_iam_policy_document.no_www_policy.json}"
}

resource "aws_s3_bucket_policy" "www" {
	bucket = "${aws_s3_bucket.www.id}"
	policy = "${data.aws_iam_policy_document.www_policy.json}"
}

resource "aws_s3_bucket_policy" "assets" {
	bucket = "${aws_s3_bucket.assets.id}"
	policy = "${data.aws_iam_policy_document.assets_policy.json}"
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# ACM Certificate
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "aws_acm_certificate" "cert" {
	domain_name       		= "${var.domain_name}"
	subject_alternative_names	= ["*.${var.domain_name}"]
	validation_method 		= "DNS"
}

resource "aws_route53_record" "cert_validation" {
	name	= "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
	type	= "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
	zone_id	= "${aws_route53_zone.main.zone_id}"
	records	= ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
	ttl	= 60
}

resource "aws_acm_certificate_validation" "cert" {
	certificate_arn = "${aws_acm_certificate.cert.arn}"
	validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# CloudFront
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
	comment = "Static content for ${var.domain_name}"
}

resource "aws_cloudfront_distribution" "no_www" {
	origin {
		domain_name	= "${local.dashed_domain_name}.s3-website-us-east-1.amazonaws.com"
		origin_id	= "S3-${local.dashed_domain_name}"

		custom_origin_config {
			http_port = 80
			https_port = 443
			origin_protocol_policy = "http-only"
			origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
		}
	}

	enabled		= true
	is_ipv6_enabled	= true
	comment	= "${var.domain_name}"

	logging_config {
		include_cookies	= false
		bucket		= "${aws_s3_bucket.logs.bucket_regional_domain_name}"
		prefix		= "${local.dashed_domain_name}/"
	}

	aliases = ["${var.domain_name}"]

	default_cache_behavior {
		allowed_methods  = ["GET", "HEAD"]
		cached_methods   = ["GET", "HEAD"]
		target_origin_id = "S3-${local.dashed_domain_name}"

		forwarded_values {
			query_string = false

			cookies {
				forward = "none"
			}
		}

		viewer_protocol_policy = "redirect-to-https"
		min_ttl                = 0
		default_ttl            = 86400
		max_ttl                = 31536000
		compress               = true
	}

	price_class = "PriceClass_All"

	restrictions {
		geo_restriction {
			restriction_type = "none"
		}
	}

	viewer_certificate {
		acm_certificate_arn	= "${aws_acm_certificate_validation.cert.certificate_arn}"
		ssl_support_method	= "sni-only"
	}
}

resource "aws_cloudfront_distribution" "www" {
	origin {
		domain_name	= "www-${local.dashed_domain_name}.s3-website-us-east-1.amazonaws.com"
		origin_id	= "S3-www-${local.dashed_domain_name}"

		custom_origin_config {
			http_port = 80
			https_port = 443
			origin_protocol_policy = "http-only"
			origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
		}
	}

	enabled		= true
	is_ipv6_enabled	= true
	comment	= "www.${var.domain_name}"

	aliases = ["www.${var.domain_name}"]

	default_cache_behavior {
		allowed_methods  = ["GET", "HEAD"]
		cached_methods   = ["GET", "HEAD"]
		target_origin_id = "S3-www-${local.dashed_domain_name}"

		forwarded_values {
			query_string = false

			cookies {
				forward = "none"
			}
		}

		viewer_protocol_policy = "redirect-to-https"
		min_ttl                = 0
		default_ttl            = 86400
		max_ttl                = 31536000
	}

	price_class = "PriceClass_All"

	restrictions {
		geo_restriction {
			restriction_type = "none"
		}
	}

	viewer_certificate {
		acm_certificate_arn	= "${aws_acm_certificate_validation.cert.certificate_arn}"
		ssl_support_method	= "sni-only"
	}
}

resource "aws_cloudfront_distribution" "assets" {
	origin {
		domain_name	= "${aws_s3_bucket.assets.bucket_domain_name}"
		origin_id	= "S3-assets-${local.dashed_domain_name}"

		s3_origin_config {
			origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
		}
	}

	enabled		= true
	is_ipv6_enabled	= true
	comment	= "assets.${var.domain_name}"

	aliases = ["assets.${var.domain_name}"]

	default_cache_behavior {
		allowed_methods  = ["GET", "HEAD"]
		cached_methods   = ["GET", "HEAD"]
		target_origin_id = "S3-assets-${local.dashed_domain_name}"

		forwarded_values {
			query_string = false

			cookies {
				forward = "none"
			}
		}

		viewer_protocol_policy = "redirect-to-https"
		min_ttl                = 0
		default_ttl            = 86400
		max_ttl                = 31536000
		compress               = true
	}

	price_class = "PriceClass_All"

	restrictions {
		geo_restriction {
			restriction_type = "none"
		}
	}

	viewer_certificate {
		acm_certificate_arn	= "${aws_acm_certificate_validation.cert.certificate_arn}"
		ssl_support_method	= "sni-only"
	}
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Route 53
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "aws_route53_record" "no_www" {
	zone_id = "${aws_route53_zone.main.zone_id}"
	name    = "${var.domain_name}"
	type    = "A"

	alias {
		name                   = "${aws_cloudfront_distribution.no_www.domain_name}"
		zone_id                = "${aws_cloudfront_distribution.no_www.hosted_zone_id}"
		evaluate_target_health = false
	}
}

resource "aws_route53_record" "www" {
	zone_id = "${aws_route53_zone.main.zone_id}"
	name    = "www"
	type    = "A"

	alias {
		name                   = "${aws_cloudfront_distribution.www.domain_name}"
		zone_id                = "${aws_cloudfront_distribution.www.hosted_zone_id}"
		evaluate_target_health = false
	}
}

resource "aws_route53_record" "assets" {
	zone_id = "${aws_route53_zone.main.zone_id}"
	name    = "assets"
	type    = "A"

	alias {
		name                   = "${aws_cloudfront_distribution.assets.domain_name}"
		zone_id                = "${aws_cloudfront_distribution.assets.hosted_zone_id}"
		evaluate_target_health = false
	}
}
