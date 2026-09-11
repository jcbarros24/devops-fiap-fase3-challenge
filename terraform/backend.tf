# Backend remoto (Requisito de Estado do Tech Challenge Fase 3).
#
# O bloco "backend" do Terraform NÃO aceita variáveis — troque o valor de
# "bucket" abaixo pelo output `bucket_name` do módulo terraform/bootstrap
# (rode o bootstrap primeiro, veja terraform/bootstrap/main.tf).
#
# use_lockfile = true ativa o lock nativo do S3 (Terraform >= 1.10),
# dispensando uma tabela DynamoDB só para lock, conforme visto na Aula 2 de IaC.
terraform {
  backend "s3" {
    bucket       = "CHANGE-ME-togglemaster-tfstate-xxxxxxxx" # output do bootstrap
    key          = "fase3-challenge/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
