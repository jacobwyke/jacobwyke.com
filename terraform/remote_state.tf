resource "aws_s3_bucket" "terraform-state-storage-s3" {
	bucket = "terraform-${local.dashed_domain_name}"

	versioning {
		enabled = true
	}

	lifecycle {
		prevent_destroy = true
	}
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
	name = "terraform-state-lock-dynamo"
	hash_key = "LockID"
	read_capacity = 20
	write_capacity = 20

	attribute {
		name = "LockID"
		type = "S"
	}
}