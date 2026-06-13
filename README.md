# ShopSphere — Kubernetes / Helm

## Architecture

```
                         ┌─────────────────────────────────┐
   Internet ────────────▶│  storefront (LoadBalancer)       │
                         │  React + Nginx                   │
                         └───────────────┬───────────────────┘
                                          │ calls
                         ┌───────────────▼───────────────────┐
   Internet ────────────▶│  api-gateway (LoadBalancer)       │
                         └───────────────┬───────────────────┘
                                          │ routes to (ClusterIP, internal)
        ┌──────────┬──────────┬──────────┼──────────┬──────────────┐
        ▼          ▼          ▼          ▼          ▼              ▼
   auth-service product- order-   payment- inventory- notification-
               service   service  service  service    service
        │          │          │          │          │              │
        └──────────┴──────────┴────┬─────┴──────────┴──────────────┘
                                    │
                          discovery-server (Eureka)
                                    │
                    ┌───────────────┼────────────────┐
                    ▼               ▼                ▼
              RDS (x6, via       MSK (Kafka)    ElastiCache (Redis)
              shopsphere-connections Secret)
```

## One chart, nine deployments

`helm/microservice/` is a single reusable chart (Deployment + Service +
health checks). `values/*.yaml` — one per service — fill in the
image, port, and env vars that differ. This mirrors how
docker-compose.yml had one repeated shape (`build:`, `ports:`,
`environment:`) for each service.

## Prerequisites

1. **Terraform applied** (or at least the RDS/MSK/ElastiCache modules) —
   so real endpoints exist
2. **Ansible secrets generated**:
   ```cmd
   cd ansible
   ansible-playbook -i inventory/hosts.ini playbooks/generate-k8s-secrets.yml -e "db_password=YourPassword"
   ```
   This writes `kubernetes/base/secrets.generated.yaml`
3. **Docker images pushed** to a registry (GitHub Container Registry,
   ECR, etc.) — each `values/*.yaml` currently points at
   `ghcr.io/shopsphere-platform/<service>:latest` as a placeholder.
   Your existing Dockerfiles (from docker-compose) work as-is for this —
   just `docker build` + `docker push` to the registry.
4. **kubectl configured** for your EKS cluster:
   ```cmd
   aws eks update-kubeconfig --region us-east-2 --name shopsphere-dev
   ```

## Deploy order

```cmd
kubectl apply -f namespace.yaml
kubectl apply -f base/secrets.generated.yaml
cd values
bash deploy-all.sh
```

## Useful commands

```cmd
kubectl get pods -n shopsphere
kubectl get svc -n shopsphere
kubectl logs -f deployment/api-gateway -n shopsphere
kubectl rollout restart deployment/product-service -n shopsphere
helm uninstall product-service -n shopsphere
```

## application.yml changes needed for production

Each service's `application.yml` should read from environment
variables (Spring does this automatically via relaxed binding):

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${PRODUCTS_DB_HOST}/shopsphere_products
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  kafka:
    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS}
  data:
    redis:
      host: ${REDIS_HOST}
```

These env vars are injected by `envFromSecretRefs: [shopsphere-connections]`
in each values file — same `${VAR}` pattern Spring Boot already
understands, just sourced from Kubernetes instead of docker-compose's
`environment:` block.
