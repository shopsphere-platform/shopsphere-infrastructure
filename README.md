# ShopSphere — Infrastructure

Complete Infrastructure-as-Code for ShopSphere: Terraform provisions AWS resources, Ansible bridges Terraform outputs into Kubernetes, and Helm deploys all 9 components.

---

# Terraform

| Module | AWS Resources | Replaces |
|---|---|---|
| `vpc` | VPC, subnets, NAT Gateway | Docker network |
| `eks` | EKS cluster + node group + IAM | Docker host |
| `rds` | 6x RDS Postgres | 6x postgres containers |
| `msk` | Managed Kafka cluster | kafka + zookeeper containers |
| `elasticache` | Managed Redis | redis container |

```cmd
cd terraform/environments/dev
terraform init
terraform plan   # free, read-only
```

---

# Ansible

| Playbook | Purpose |
|---|---|
| `bastion-setup.yml` | Install kubectl/helm/aws-cli on jump-box EC2 |
| `generate-k8s-secrets.yml` | Read terraform outputs → generate Kubernetes Secret |

```cmd
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/generate-k8s-secrets.yml -e "db_password=YourPassword"
```

---

# Kubernetes / Helm

One reusable chart (`helm/microservice/`) deployed 9 times with different `values/*.yaml` files.