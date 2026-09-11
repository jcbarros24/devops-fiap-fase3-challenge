variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group (dos nodes do EKS) autorizado a acessar o Postgres na porta 5432."
  type        = string
}

variable "db_instances" {
  type = map(object({
    db_name  = string
    username = string
  }))
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "instance_class" {
  type = string
}

variable "engine_version" {
  type = string
}
