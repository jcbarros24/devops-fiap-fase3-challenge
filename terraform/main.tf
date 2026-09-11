locals {
  cluster_name = "${var.project_name}-${var.environment}"
}

module "networking" {
  source = "./modules/networking"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  azs                   = var.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  cluster_name          = local.cluster_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = local.cluster_name
  kubernetes_version   = var.kubernetes_version
  lab_role_name        = var.lab_role_name
  public_subnet_ids    = module.networking.public_subnet_ids
  private_subnet_ids   = module.networking.private_subnet_ids
  node_instance_types  = var.node_instance_types
  node_desired_size    = var.node_desired_size
  node_min_size        = var.node_min_size
  node_max_size        = var.node_max_size
}

module "rds" {
  source = "./modules/rds"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  private_subnet_ids         = module.networking.private_subnet_ids
  allowed_security_group_id  = module.eks.cluster_security_group_id
  db_instances                = var.db_instances
  db_password                 = var.db_password
  instance_class               = var.db_instance_class
  engine_version                = var.db_engine_version
}

module "elasticache" {
  source = "./modules/elasticache"

  project_name              = var.project_name
  environment                = var.environment
  vpc_id                      = module.networking.vpc_id
  private_subnet_ids          = module.networking.private_subnet_ids
  allowed_security_group_id  = module.eks.cluster_security_group_id
  node_type                   = var.redis_node_type
}

module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = var.dynamodb_table_name
}

module "sqs" {
  source = "./modules/sqs"

  queue_name = var.sqs_queue_name
}

module "ecr" {
  source = "./modules/ecr"

  repository_names = var.ecr_repository_names
}

# --- ArgoCD --------------------------------------------------------------
# Instalado via provider Helm apontando pro cluster criado acima (em vez de
# um módulo separado, para simplificar a passagem de providers configurados
# dinamicamente a partir dos outputs do EKS).
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [module.eks]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # server em ClusterIP + port-forward é suficiente pro vídeo de demonstração;
  # troque para LoadBalancer se quiser expor publicamente.
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  depends_on = [module.eks]
}
