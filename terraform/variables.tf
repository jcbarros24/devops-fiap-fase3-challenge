variable "aws_region" {
  description = "Região AWS onde toda a infraestrutura é provisionada."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefixo usado no nome de todos os recursos."
  type        = string
  default     = "togglemaster"
}

variable "environment" {
  description = "Ambiente (ex: hml, prod)."
  type        = string
  default     = "hml"
}

# --- Restrição AWS Academy -------------------------------------------------
variable "use_lab_role" {
  description = "Se true (AWS Academy), usa a LabRole existente via data source em vez de criar roles de IAM novas."
  type        = bool
  default     = true
}

variable "lab_role_name" {
  description = "Nome da role existente no AWS Academy usada pelo cluster EKS e pelos Node Groups."
  type        = string
  default     = "LabRole"
}

# --- Networking --------------------------------------------------------------
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  description = "AZs usadas (2, para atender ao requisito de multi-AZ do EKS/RDS)."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

# --- EKS -----------------------------------------------------------------
variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

# --- Bancos de dados -------------------------------------------------------
variable "db_instances" {
  description = "Um RDS PostgreSQL por serviço que precisa de banco relacional."
  type = map(object({
    db_name  = string
    username = string
  }))
  default = {
    auth-service = {
      db_name  = "auth_db"
      username = "auth_user"
    }
    flag-service = {
      db_name  = "flags_db"
      username = "flag_user"
    }
    targeting-service = {
      db_name  = "targeting_db"
      username = "targeting_user"
    }
  }
}

variable "db_password" {
  description = "Senha usada nas 3 instâncias RDS (defina via terraform.tfvars ou variável de ambiente TF_VAR_db_password, nunca commitada)."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_engine_version" {
  type    = string
  default = "16.4"
}

# --- Redis / ElastiCache ----------------------------------------------------
variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}

# --- DynamoDB ----------------------------------------------------------------
variable "dynamodb_table_name" {
  type    = string
  default = "ToggleMasterAnalytics"
}

# --- SQS -----------------------------------------------------------------
variable "sqs_queue_name" {
  type    = string
  default = "togglemaster-events"
}

# --- ECR -----------------------------------------------------------------
variable "ecr_repository_names" {
  type = list(string)
  default = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service",
  ]
}

# --- ArgoCD ----------------------------------------------------------------
variable "argocd_chart_version" {
  description = "Versão do chart Helm argo-cd (argoproj/argo-helm)."
  type        = string
  default     = "7.7.11"
}
