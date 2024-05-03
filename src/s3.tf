terraform {
  backend "s3" {
    bucket         = "task-6-2"
    key            = "terraform/terraform.tfstate" #提前去S3上建好,terraform資料夾
    region         = "ap-northeast-1"
    dynamodb_table = "task-6-2"
    encrypt        = true
  }
}
