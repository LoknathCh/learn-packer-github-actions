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

source "azure-arm" "windows-2016" {
  azure_tags = {
    dept = "System Engineering"
    task = "Windows VM Image deployment"
  }
  build_resource_group_name         = "gimgpocRG"
  client_id                         = "379f9cf9-247e-4289-923a-d701e876e0b1"
  client_secret                     = "DQl8Q~9L8cA8dHMl2LnnN-tEreqFskR1UqIojak6"
  communicator                      = "winrm"
  image_offer                       = "WindowsServer"
  image_publisher                   = "MicrosoftWindowsServer"
  image_sku                         = "2016-Datacenter"
  managed_image_name                = "packer_Azure_Windows_{{timestamp}}_v${var.version}"
  managed_image_resource_group_name = "gimgpocRG"
  os_type                           = "Windows"
  subscription_id                   = "b391cc0b-e637-4543-bb37-2c8c78e135cf"
  tenant_id                         = "9b94192d-9d69-46d4-a7f7-733234e26805"
  vm_size                           = "Standard_D2_v2"
  winrm_insecure                    = true
  winrm_timeout                     = "5m"
  winrm_use_ssl                     = true
  winrm_username                    = "packer"
}

build {

  hcp_packer_registry {
    bucket_name = "learn-packer-azure-windows-github-actions-01"
    description = "Github Actions HCP Packer Terraform Cloud Run POC"

    bucket_labels = {
      "hashicorp-learn" = "learn-packer-github-actions",
    }
  }

  sources = ["source.azure-arm.windows-2016"]

  provisioner "powershell" {
    inline = ["Add-WindowsFeature Web-Server", "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }", "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }", "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit", "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"]
  }

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      iteration_id = packer.iterationID
    }
  }

}
