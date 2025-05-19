
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
  }
}



resource "kubernetes_manifest" "karpenter_x86_deployment" {
  manifest = yamldecode(<<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: x86-test
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: x86
      template:
        metadata:
          labels:
            app: x86
        spec:
          nodeSelector:
            kubernetes.io/arch: amd64
          containers:
            - name: test
              image: public.ecr.aws/ubuntu/ubuntu:latest
              command: ["sleep", "3600"]
  YAML
  )
}

resource "kubernetes_manifest" "karpenter_arm_deployment" {
  manifest = yamldecode(<<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: arm-test
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: arm
      template:
        metadata:
          labels:
            app: arm
        spec:
          nodeSelector:
            kubernetes.io/arch: arm64
          containers:
            - name: test
              image: public.ecr.aws/ubuntu/ubuntu:latest
              command: ["sleep", "3600"]
  YAML
  )
}
