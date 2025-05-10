# EKS + Karpenter Terraform Infrastructure

This repository provisions an Amazon EKS (Elastic Kubernetes Service) cluster using Terraform and deploys [Karpenter](https://karpenter.sh/) for dynamic and cost-efficient node provisioning. The setup supports both x86 (amd64) and ARM64 workloads using Graviton instances and spot pricing.

---

## 📦 Features

- EKS cluster with version `1.30`
- Public & private subnet topology with NAT Gateway
- EKS Managed Node Group (MNG) for core workloads and Karpenter
- Karpenter controller deployment via Helm
- Dual-architecture support: `amd64` (x86) and `arm64`
- Dynamic NodePool and NodeClass for Karpenter provisioning
- Test deployments for both x86 and ARM architectures

---

## 📁 Project Structure

./terraform/
├── main.tf # Main Terraform infrastructure setup
├── terraform.tfvars  for dynamic configuration
├── variables.tf # Input variables
├── outputs.tf # Output definitions
├── versions.tf # Provider versions
├── README.md # This file

---

## 🚀 Prerequisites

- Terraform v1.5+
- AWS CLI configured with access to the target account
- Helm installed locally (for local testing)
- `kubectl` installed and configured (optional for validation)

---

## 🛠️ Deployment Steps

Initialize Terraform
    terraform init

Preview Plan
    terraform plan

Apply Infrastructure
    terraform apply

Verify Karpenter Installation
    kubectl get pods -n kube-system -l app.kubernetes.io/name=karpenter

---

## ✅ Validating Test Deployments


x86 Workload: Schedules on amd64 nodes
    kubectl get pods -l app=x86


ARM Deployment: Will trigger an ARM64 (Graviton) node
    kubectl get pods -l app=arm

---
## 🧹 Cleanup

To destroy all resources and clean up:

terraform destroy