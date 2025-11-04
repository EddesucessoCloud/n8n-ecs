terraform {
  backend "s3" {
    bucket         = "n8n-ecs-website" # substitua pelo seu bucket de state
    key            = "infra/terraform.tfstate" # caminho dentro do bucket
    region         = "us-east-1"                   # região do bucket
    encrypt        = true
  }
}