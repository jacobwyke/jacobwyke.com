resource "aws_s3_bucket" "logs" {
    bucket = "logs-${local.dashed_domain_name}"
    acl    = "private"

    lifecycle_rule {
        id  = "Delete logs after 30 days"
        enabled = true

        prefix  = "${local.dashed_domain_name}/"

        expiration {
            days = 30
        }

        noncurrent_version_expiration {
            days = 30
        }

        abort_incomplete_multipart_upload_days = 7
    }
}