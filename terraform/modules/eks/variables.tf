variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "lab_role_name" {
  description = "Nome da LabRole existente no AWS Academy (usada tanto pelo cluster quanto pelo node group)."
  type        = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "node_instance_types" {
  type = list(string)
}

variable "node_desired_size" {
  type = number
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}
