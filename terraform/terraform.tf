terraform {
    backend "s3" {
        encrypt = true
        bucket = "terraform-jacobwyke-com"
        dynamodb_table = "terraform-state-lock-dynamo"
        region = "us-east-1"
        key = "jacobwyke-com.tfstate"
    }
}