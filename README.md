# ShopSphere — Infrastructure (Terraform + Ansible)

This repo contains the Infrastructure-as-Code for ShopSphere: Terraform provisions AWS resources, Ansible configures access and bridges Terraform outputs into Kubernetes.

---

# Terraform Infrastructure

## What this creates

| Module | AWS Resources | Replaces (from docker-compose.yml) |
|---|---|---|
| `vpc` | VPC, 2 public + 2 private subnets, IGW, NAT Gateway, route tables | Docker's `shopsphere-network` bridge |
| `eks` | EKS cluster (control plane) + managed node group + IAM roles + OIDC provider | The Docker host running your 8 service containers |
| `rds` | 6x RDS Postgres instances (auth, products, orders, payments, inventory, notifications) | `postgres-auth`, `postgres-products`, etc. |
| `msk` | 2-broker managed Kafka cluster | `kafka` + `zookeeper` containers |
| `elasticache` | Managed Redis replication group | `redis` container |

## Folder structure