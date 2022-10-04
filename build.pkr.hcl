packer {
  required_plugins {
    azure = {
      version = ">= 1.3.1"
      source  = "github.com/hashicorp/azure"
    }
  }
}


variable "version" {
  type    = string
  default = "1.0.0"
}


source "azure-arm" "ubuntu-lts" {
  azure_tags = {
    dept = "System Engineering"
    task = "Image deployment"
  }
  client_id                         = "379f9cf9-247e-4289-923a-d701e876e0b1"
  client_secret                     = "DQl8Q~9L8cA8dHMl2LnnN-tEreqFskR1UqIojak6"
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "16.04-LTS"
  location                          = "eastus"
  managed_image_name                = "packer_Azure_{{timestamp}}_v${var.version}"
  managed_image_resource_group_name = "gimgpocRG"
  os_type                           = "Linux"
  subscription_id                   = "b391cc0b-e637-4543-bb37-2c8c78e135cf"
  tenant_id                         = "9b94192d-9d69-46d4-a7f7-733234e26805"
  vm_size                           = "Standard_DS2_v2"
}


build {
  # HCP Packer settings
  hcp_packer_registry {
    bucket_name = "learn-packer-azure-github-actions-01"
    description = "Github Actions HCP Packer Terraform Cloud Run POC"

    bucket_labels = {
      "hashicorp-learn" = "learn-packer-github-actions",
    }
  }

  sources = [
    "source.azure-arm.ubuntu-lts",
  ]

  # systemd unit for HashiCups service
  provisioner "file" {
    source      = "hashicups.service"
    destination = "/tmp/hashicups.service"
  }

  # Set up HashiCups
  provisioner "shell" {
    scripts = [
      "setup-deps-hashicups.sh"
    ]
  }

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      iteration_id = packer.iterationID
    }
  }
}
