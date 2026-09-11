# Tech Challenge Fase 3 — ToggleMaster (POSTECH)

Automação completa da infraestrutura e do ciclo de vida dos 5 microsserviços
do ToggleMaster (`auth`, `flag`, `targeting`, `evaluation`, `analytics`) via
IaC (Terraform), CI/CD com DevSecOps (GitHub Actions) e GitOps (ArgoCD) num
cluster EKS.

## Arquitetura

```
services/           código-fonte dos 5 microsserviços (copiado da Fase 2)
terraform/          toda a infraestrutura AWS como código
gitops/              manifests Kubernetes que o ArgoCD sincroniza no cluster
.github/workflows/  pipelines de CI (build, lint, SAST/SCA, container scan, push ECR, gitops update)
```

- **auth-service** (Go, :8001) — Postgres próprio.
- **flag-service** (Python/Flask, :8002) — Postgres próprio.
- **targeting-service** (Python/Flask, :8003) — Postgres próprio.
- **evaluation-service** (Go, :8004) — Redis (ElastiCache) + SQS.
- **analytics-service** (Python/Flask, :8005) — DynamoDB (`ToggleMasterAnalytics`) + SQS.

## Ambiente AWS Academy

Este projeto foi escrito assumindo **AWS Academy**: nenhum recurso
`aws_iam_role`/`aws_iam_policy` é criado pelo Terraform. O cluster EKS e os
Node Groups usam a `LabRole` já existente no ambiente (via `data
"aws_iam_role"` em `terraform/modules/eks/main.tf`). Se você estiver usando
uma conta pessoal, pode trocar isso por roles próprias — não é o cenário
coberto aqui.

## Passo a passo para aplicar

1. **Bootstrap do backend remoto** (uma única vez):
   ```bash
   cd terraform/bootstrap
   terraform init
   terraform apply
   # copie o output "bucket_name"
   ```
2. Edite `terraform/backend.tf` e troque `bucket` pelo nome gerado acima.
3. **Infraestrutura principal**:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars   # ajuste db_password
   terraform init
   terraform plan
   terraform apply
   ```
   Isso cria VPC, EKS + Node Groups, 3 RDS Postgres, Redis (ElastiCache),
   DynamoDB, SQS, 5 repositórios ECR e instala o ArgoCD via Helm no cluster.
4. **Configurar o kubectl**:
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name togglemaster-hml
   ```
5. **Criar os Secrets das aplicações** (nunca em texto plano no git — copie
   `gitops/create-secrets.example.sh` para `create-secrets.sh`, preencha com
   os endpoints reais dos outputs do Terraform e rode uma vez):
   ```bash
   cp gitops/create-secrets.example.sh gitops/create-secrets.sh
   # edite os valores
   ./gitops/create-secrets.sh
   ```
6. **Registrar as Applications do ArgoCD** (depois de já ter dado `git push`
   deste repo para o GitHub — troque `<GIT_REPO_URL>` nos 5 arquivos em
   `gitops/argocd-apps/` pela URL real):
   ```bash
   kubectl apply -f gitops/namespace.yaml
   kubectl apply -f gitops/argocd-apps/
   ```
7. **Acessar a interface do ArgoCD**:
   ```bash
   kubectl -n argocd port-forward svc/argocd-server 8080:443
   kubectl -n argocd get secret argocd-initial-admin-secret \
     -o jsonpath="{.data.password}" | base64 -d
   # usuário: admin, senha: (comando acima) — https://localhost:8080
   ```

## Secrets necessários no GitHub (Settings → Secrets and variables → Actions)

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN` | Credenciais temporárias do AWS Academy (expiram em poucas horas — atualize antes de gravar o vídeo) |
| `AWS_REGION` | ex.: `us-east-1` |

`GITHUB_TOKEN` (automático) já tem permissão de push no repo (`permissions:
contents: write` nos workflows) para o job `gitops-update`.

## Pipeline de CI/CD (por serviço)

Cada serviço tem seu próprio workflow (`.github/workflows/<service>.yml`),
disparado só quando `services/<service>/**` muda, chamando um workflow
reutilizável (`reusable-go-ci.yml` ou `reusable-python-ci.yml`) com os
estágios:

1. **Build & Unit Test**
2. **Linter/Static Analysis** (`golangci-lint` / `flake8`)
3. **Security Scan (SAST & SCA)** — `gosec`/`bandit` (SAST) + `trivy fs` (SCA).
   **Regra de bloqueio**: qualquer achado CRITICAL/HIGH falha o pipeline.
4. **Docker Build & Push** (só em push na `main`) — build, `trivy image`
   (falha em CRITICAL), login e push no ECR com tag `v1.0.0-<commit-sha>`.
5. **GitOps update** — reescreve a tag da imagem em
   `gitops/<service>/deployment.yaml` e comita nesse mesmo repositório; o
   ArgoCD detecta a mudança e sincroniza automaticamente no cluster.

### Como demonstrar a falha de segurança pro vídeo

Adicione uma dependência com vulnerabilidade conhecida (ex.: uma versão
antiga de `requests` no `requirements.txt` de um serviço Python, ou de um
pacote Go vulnerável no `go.mod`), abra um PR — o job `security-scan` deve
falhar no Trivy/gosec/bandit. Reverta a dependência e mostre o pipeline
passando.

## Módulos Terraform

| Módulo | Recursos |
|---|---|
| `networking` | VPC, subnets públicas/privadas, IGW, 1 NAT Gateway, route tables |
| `eks` | Cluster EKS + Node Group (usa `LabRole`) |
| `rds` | 3x RDS PostgreSQL (auth, flag, targeting) |
| `elasticache` | 1x Redis (evaluation-service) |
| `dynamodb` | Tabela `ToggleMasterAnalytics` (hash key `event_id`) |
| `sqs` | 1 fila (`togglemaster-events`) |
| `ecr` | 5 repositórios com scan-on-push e lifecycle policy |

ArgoCD é instalado direto em `terraform/main.tf` (não como módulo) via
`helm_release`, pois precisa dos providers `kubernetes`/`helm` já
configurados com os outputs do EKS — ver `terraform/providers.tf`.

## Trade-offs assumidos (documentar no relatório)

- **1 único NAT Gateway** (em vez de 1 por AZ) para reduzir custo — ponto
  único de falha aceitável para um ambiente de estudo/homologação.
- **RDS/Redis sem multi-AZ** — mesmo motivo.
- **SAST/SCA com Trivy + gosec/bandit** em vez de SonarCloud — evita
  depender de uma conta externa com sessão que pode expirar antes do vídeo.
- **AWS_ACCESS_KEY_ID/SECRET** no `analytics-service` em vez de IRSA — o
  AWS Academy não permite criar as IAM Roles que o IRSA exigiria.

## Pendências para o usuário

- Criar o repositório no GitHub e dar `git push` (este projeto foi
  inicializado localmente com `git init`, sem remoto configurado).
- Preencher `<GIT_REPO_URL>` nos 5 arquivos `gitops/argocd-apps/*.yaml`.
- Preencher `<AWS_ACCOUNT_ID>`/tag inicial nas imagens dos
  `gitops/*/deployment.yaml` (ou deixar rodar o primeiro pipeline).
- Preencher `RELATORIO.md`.
