
provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [var.aws_account_id]
}


provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "us-east-1"]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "us-east-1"]
  }
  
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }

      kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
  }
  
  backend "s3" {
    bucket = "851725384896-bucket-state-file-karpenter"
    key    = "karpenter.tfstate"
    region = "us-east-1"
  }
}



module "vpc" {
  source       = "./modules/vpc"
  cluster_name = var.cluster_name
  region       = var.region
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  intra_subnets   = module.vpc.intra_subnets
}

module "karpenter" {
  source          = "./modules/karpenter"
  providers = {
    kubernetes = kubernetes
  }
  cluster_name    = var.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  depends_on = [module.eks]
}

module "deployments" {
  source       = "./modules/deployments"
  cluster_name    = var.cluster_name
  depends_on = [module.eks]
  
}

resource "kubernetes_manifest" "karpenter_node_pool" {
  manifest = yamldecode(<<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
          requirements:
            - key: "kubernetes.io/arch"
              operator: In
              values: ["amd64", "arm64"]
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["t", "m", "c", "a"]
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["4", "8", "16", "32"]
            - key: "karpenter.k8s.aws/instance-hypervisor"
              operator: In
              values: ["nitro"]
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"]
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML
  )
  depends_on = [kubernetes_manifest.karpenter_node_class]
}


resource "kubernetes_manifest" "karpenter_node_class" {
  manifest = yamldecode(<<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
  YAML
  )
  depends_on = [module.karpenter]
}

