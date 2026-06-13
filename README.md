# ShopSphere — Ansible

## What's here

| File | Purpose |
|---|---|
| `inventory/hosts.ini` | Lists which machines Ansible manages — a bastion host (SSH target) and `localhost` (for local-only tasks) |
| `playbooks/bastion-setup.yml` | Installs AWS CLI, kubectl, Helm, psql on a jump-box EC2 instance for accessing private RDS/EKS resources |
| `playbooks/generate-k8s-secrets.yml` | Reads `terraform output -json` and generates a Kubernetes Secret manifest with real DB/Kafka/Redis endpoints |
| `templates/k8s-secret.yml.j2` | Jinja2 template — the shape of the generated Secret |

## Where Ansible fits in the overall pipeline

```
Terraform  →  creates VPC, EKS, RDS, MSK, ElastiCache (the infrastructure)
   ↓
Ansible    →  (1) configures a bastion host for ops access
              (2) generates Kubernetes secrets from Terraform's outputs
   ↓
Kubernetes/Helm  →  deploys the 8 Spring Boot services + React frontend,
                     consuming the secrets Ansible generated
```

## Prerequisites

```cmd
pip install ansible --break-system-packages
ansible --version
```

## Running the secrets playbook (after terraform apply)

```cmd
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/generate-k8s-secrets.yml -e "db_password=YourTerraformPassword"
```

This is safe to run anytime — it only reads Terraform state and writes a local YAML file, doesn't touch AWS.

## Running the bastion setup (requires a running bastion EC2 instance)

1. Launch a small EC2 instance (t3.micro, Ubuntu) in a public subnet — give it an IAM role with `eks:DescribeCluster` permission
2. Add its public IP + SSH key to `inventory/hosts.ini`
3. Run:
```cmd
ansible-playbook -i inventory/hosts.ini playbooks/bastion-setup.yml
```
