# ShopSphere — Terraform Infrastructure

## What this creates

| Module | AWS Resources | Replaces (from docker-compose.yml) |
|---|---|---|
| `vpc` | VPC, 2 public + 2 private subnets, IGW, NAT Gateway, route tables | Docker's `shopsphere-network` bridge |
| `eks` | EKS cluster (control plane) + managed node group + IAM roles + OIDC provider | The Docker host running your 8 service containers |
| `rds` | 6x RDS Postgres instances (auth, products, orders, payments, inventory, notifications) | `postgres-auth`, `postgres-products`, etc. |
| `msk` | 2-broker managed Kafka cluster | `kafka` + `zookeeper` containers |
| `elasticache` | Managed Redis replication group | `redis` container |

## Folder structure

```
terraform/
├── modules/              # reusable blueprints — no real values
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   ├── msk/
│   └── elasticache/
└── environments/
    └── dev/               # actual config — wires modules together
        ├── provider.tf
        ├── variables.tf
        ├── main.tf         # <- calls all 5 modules
        ├── outputs.tf
        └── terraform.tfvars.example
```

## How to run it (FREE — read-only)

### 1. Install Terraform
```cmd
winget install Hashicorp.Terraform
```

### 2. Configure AWS CLI credentials
```cmd
aws configure
```
Paste in your `terraform-admin` IAM user's Access Key ID and Secret Access Key (from earlier setup). Region: `us-east-2`.

### 3. Set your variables
```cmd
cd terraform\environments\dev
copy terraform.tfvars.example terraform.tfvars
```
Edit `terraform.tfvars` and set a real `db_password`.

### 4. Initialize
```cmd
terraform init
```
Downloads the AWS + TLS provider plugins. Free, no AWS resources touched.

### 5. Plan (the important one — completely free)
```cmd
terraform plan
```
This is the proof for your portfolio. Terraform talks to AWS to check what currently exists, compares it to your code, and prints something like:

```
Plan: 23 to add, 0 to change, 0 to destroy.
```

Save this output (screenshot or `terraform plan > plan-output.txt`) — this is what you show in interviews and your README.

### 6. (Optional, costs money) Apply
```cmd
terraform apply
```
Only run this if you've decided to do a short paid demo. Remember to run `terraform destroy` afterward to stop billing.

## Why each design decision

- **6 separate RDS instances instead of 1 shared DB** — mirrors your microservices architecture exactly: each service owns its database, matching the 6 Postgres containers in docker-compose.yml. (In a real cost-sensitive setup you might consolidate to 1-2 instances with multiple schemas — worth discussing as a tradeoff in interviews.)
- **Private subnets for everything except NAT/load balancers** — defense in depth. RDS, MSK, ElastiCache, and EKS nodes are never directly internet-reachable.
- **Security groups reference `module.eks.cluster_security_group_id`** — only pods running in your EKS cluster can talk to the databases, Kafka, and Redis. Nothing else on the internet can.
- **OIDC provider on the EKS module** — sets up IAM Roles for Service Accounts (IRSA), the modern way for individual pods to get AWS permissions without hardcoding access keys into your Spring Boot config.
