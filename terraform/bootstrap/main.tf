# Bootstrap: cria o bucket S3 que guarda o terraform.tfstate remoto da
# infraestrutura principal (terraform/). Este módulo usa state LOCAL de
# propósito — é a única forma de resolver o problema do "ovo e da galinha"
# (não dá pra guardar o state do bucket dentro do próprio bucket).
#
# Rode isto ANTES de tudo, uma única vez:
#   cd terraform/bootstrap && terraform init && terraform apply
# Depois copie o nome do bucket (output) para terraform/backend.tf.

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "Região AWS onde o bucket de state será criado."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefixo usado no nome do bucket (deve ser globalmente único)."
  type        = string
  default     = "togglemaster"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-tfstate-${random_id.suffix.hex}"

  # AWS Academy costuma derrubar o ambiente ao final do lab; força_destroy
  # evita ficar com um bucket "preso" cheio de versões antigas do state.
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name" {
  description = "Nome do bucket a ser usado em terraform/backend.tf"
  value       = aws_s3_bucket.terraform_state.bucket
}
