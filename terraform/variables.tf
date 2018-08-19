variable "aws_access_key" {
	type		= "string"
	description	= "AWS Access Key ID"
}

variable "aws_secret_key" {
	type		= "string"
	description	= "AWS Secret Access Key"
}

variable "aws_default_region" {
	type		= "string"
	description	= "Default AWS region"
}

variable "domain_name" {
	type		= "string"
	description	= "The domain name you are using"
}

locals {
	dashed_domain_name 	= "${replace(var.domain_name, ".", "-")}"
}
