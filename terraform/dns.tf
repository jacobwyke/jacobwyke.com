#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Route 53
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "aws_route53_zone" "main" {
    name = "${var.domain_name}"
}

resource "aws_route53_record" "ns" {
    zone_id = "${aws_route53_zone.main.zone_id}"
    name    = "${var.domain_name}"
    type    = "NS"
    ttl     = "172800"

    records = [
        "${aws_route53_zone.main.name_servers.0}",
        "${aws_route53_zone.main.name_servers.1}",
        "${aws_route53_zone.main.name_servers.2}",
        "${aws_route53_zone.main.name_servers.3}",
    ]
}

resource "aws_route53_record" "mx" {
    zone_id = "${aws_route53_zone.main.zone_id}"
    name    = "${var.domain_name}"
    type    = "MX"
    ttl     = "86400"

    records = [
        "1 in1-smtp.messagingengine.com",
        "10 in2-smtp.messagingengine.com",
        "20 smtp.secureserver.net",
        "30 mailstore1.secureserver.net",
    ]
}

resource "aws_route53_record" "txt" {
    zone_id = "${aws_route53_zone.main.zone_id}"
    name    = "${var.domain_name}"
    type    = "TXT"
    ttl     = "86400"

    records = [
        "google-site-verification=g98WN9owqS9_5s9tcqK6PWGWuW29Q9-W7dzKMn4xw0Y",
        "v=spf1 include:spf.messagingengine.com ?all"
    ]
}

# FastMail records
resource "aws_route53_record" "fastmail_fm1" {
    zone_id = "${aws_route53_zone.main.zone_id}"
    name    = "fm1._domainkey"
    type    = "CNAME"
    ttl     = "86400"

    records = [
        "fm1.jacobwyke.com.dkim.fmhosted.com",
    ]
}

resource "aws_route53_record" "fastmail_fm2" {
    zone_id = "${aws_route53_zone.main.zone_id}"
    name    = "fm2._domainkey"
    type    = "CNAME"
    ttl     = "86400"

    records = [
        "fm2.jacobwyke.com.dkim.fmhosted.com",
    ]
}

resource "aws_route53_record" "fastmail_fm3" {
    zone_id = "${aws_route53_zone.main.zone_id}"
    name    = "fm3._domainkey"
    type    = "CNAME"
    ttl     = "86400"

    records = [
        "fm3.jacobwyke.com.dkim.fmhosted.com",
    ]
}

resource "aws_route53_record" "fastmail_dkim" {
    zone_id = "${aws_route53_zone.main.zone_id}"
    name    = "mesmtp._domainkey"
    type    = "CNAME"
    ttl     = "86400"

    records = [
        "mesmtp.jacobwyke.com.dkim.fmhosted.com",
    ]
}

resource "aws_route53_record" "fastmail_imaps" {

    zone_id = "${aws_route53_zone.main.zone_id}"
    name    = "_imaps._tcp"
    type    = "SRV"
    ttl     = "86400"

    records = [
        "0 1 993 imap.fastmail.com",
    ]
}

resource "aws_route53_record" "fastmail_smtp" {
    zone_id = "${aws_route53_zone.main.zone_id}"
    name    = "_submission._tcp"
    type    = "SRV"
    ttl     = "86400"

    records = [
        "0 1 587 smtp.fastmail.com",
    ]
}