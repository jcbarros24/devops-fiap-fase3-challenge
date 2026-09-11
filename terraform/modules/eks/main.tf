# Restrição AWS Academy: não criamos nenhuma aws_iam_role/aws_iam_policy
# aqui. A LabRole já existe no ambiente e tem as policies necessárias
# (EKS, EC2, ECR, etc.) anexadas manualmente pelo Academy.
data "aws_iam_role" "lab_role" {
  name = var.lab_role_name
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.lab_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_public_access   = true
    endpoint_private_access  = true
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-default"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  # A LabRole já concede permissão de nó do EKS por padrão no ambiente
  # Academy; não é necessário (nem permitido) anexar policies aqui.
  depends_on = [aws_eks_cluster.this]
}
