terraform {
    backend "s3"{
        bucket = "terraform-state-1742265940"
        key = "terraform.tfstate"
        region = "ap-northeast-2"
        dynamodb_table = "terraform-lock"
        encrypt = true
    }
}