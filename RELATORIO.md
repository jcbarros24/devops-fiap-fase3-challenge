# Relatório de Entrega — Tech Challenge Fase 3

## Participantes
- <NOME COMPLETO> — RM <NÚMERO>
- <adicionar demais integrantes do grupo>

## Links
- Repositório: <URL do GitHub>
- Vídeo de demonstração: <URL — YouTube não listado, Drive, etc.>
- Documentação adicional (se houver): <URL>

## Resumo dos desafios encontrados e decisões tomadas

<Preencher com base na experiência real de quem rodou o projeto. Pontos que
provavelmente valem menção — ver também a seção "Trade-offs assumidos" do
README.md:>

- Restrição do AWS Academy (sem criar IAM) e como a LabRole foi associada
  ao EKS/Node Groups via `data source`.
- Escolha de Trivy + gosec/bandit para SAST/SCA em vez de SonarCloud.
- Como o backend remoto do Terraform foi resolvido (bootstrap com state
  local criando o bucket S3, depois `use_lockfile` para o lock).
- Trade-offs de custo assumidos (1 NAT Gateway, sem multi-AZ em RDS/Redis).
- Qualquer erro/obstáculo real encontrado durante o `terraform apply` ou a
  configuração do ArgoCD, e como foi resolvido.

## Print da estimativa de custos da AWS

<Inserir print do AWS Pricing Calculator ou do Cost Explorer aqui>
