terraform {
    required_providers {
        minikube = {
            source = "scott-the-programmer/minikube"
            version = "0.4.2"
        }
        helm = {
            source  = "hashicorp/helm"
            version = "2.16.1" # Use the version specified in the tutorial
        }
    }
}

provider "minikube" {
    kubernetes_version = "v1.30.0"
}

resource "minikube_cluster" "minikube_docker" {
    driver = "docker"
    cluster_name = "devops-project-2025"
    addons = [
        "default-storageclass",
        "storage-provisioner",
    ]
}
