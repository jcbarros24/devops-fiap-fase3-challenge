#!/usr/bin/env bash
# Cria os Secrets do Kubernetes com as credenciais reais de cada serviço.
#
# Este arquivo é um EXEMPLO propositalmente sem valores reais — é o oposto
# do problema apontado no desafio ("credenciais em arquivos de texto sem
# segurança"). Copie para create-secrets.sh (já ignorado pelo git), preencha
# os valores reais (pegue os endpoints nos outputs do `terraform apply`) e
# rode uma vez contra o cluster, manualmente, FORA do pipeline de CI.
set -euo pipefail

kubectl create namespace togglemaster --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic auth-service-secrets \
  --namespace togglemaster \
  --from-literal=DATABASE_URL="postgres://auth_user:<SENHA>@<RDS_AUTH_ENDPOINT>/auth_db?sslmode=require" \
  --from-literal=MASTER_KEY="<GERE_UMA_CHAVE_FORTE>" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic flag-service-secrets \
  --namespace togglemaster \
  --from-literal=DATABASE_URL="postgres://flag_user:<SENHA>@<RDS_FLAG_ENDPOINT>/flags_db?sslmode=require" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic targeting-service-secrets \
  --namespace togglemaster \
  --from-literal=DATABASE_URL="postgres://targeting_user:<SENHA>@<RDS_TARGETING_ENDPOINT>/targeting_db?sslmode=require" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic evaluation-service-secrets \
  --namespace togglemaster \
  --from-literal=REDIS_URL="redis://<ELASTICACHE_ENDPOINT>:6379" \
  --from-literal=SERVICE_API_KEY="<CHAVE_GERADA_NO_AUTH_SERVICE>" \
  --from-literal=AWS_SQS_URL="<SQS_QUEUE_URL>" \
  --from-literal=AWS_REGION="us-east-1" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic analytics-service-secrets \
  --namespace togglemaster \
  --from-literal=AWS_REGION="us-east-1" \
  --from-literal=AWS_SQS_URL="<SQS_QUEUE_URL>" \
  --from-literal=AWS_DYNAMODB_TABLE="ToggleMasterAnalytics" \
  --from-literal=AWS_ACCESS_KEY_ID="<ACCESS_KEY>" \
  --from-literal=AWS_SECRET_ACCESS_KEY="<SECRET_KEY>" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets aplicados no namespace togglemaster."
