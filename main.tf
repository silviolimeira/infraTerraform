terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.token
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "jenkins" {
  image  = "ubuntu-22-04-x64"
  name   = "jenkins"
  region = var.region
  size   = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.ssy_key.id]
}

data "digitalocean_ssh_key" "ssy_key" {
  name = var.ssh_key_name
}


# DEFININDO O CLUSTER KUBERNETES

resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = "nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.24.4-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 2

  }
}

# PARAMETRIZANDO ALGUMAS CONFIGURAÇÕES

variable "region" {
    default = ""
}
variable "token" {
    default = ""
}
variable "ssh_key_name" {
    default = ""
}

# CAPTURANDO O IP DO DROPLET JENKINS 

output "jenkins_ip" {
    value = digitalocean_droplet.jenkins.ipv4_address
}

# PRESQUISAR NA DOCUMENTAÇÃO LOCAL_FILE

resource "local_file" "foo" {
    content = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
    filename = "kube_config.yaml"
}