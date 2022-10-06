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
  client_id                         = "${env("AZURE_CLIENT_ID")}"
  client_secret                     = "${env("AZURE_CLIENT_SECRET")}"
  communicator                      = "winrm"
  image_offer                       = "WindowsServer"
  image_publisher                   = "MicrosoftWindowsServer"
  image_sku                         = "2016-Datacenter"
  managed_image_name                = "packer_Azure_Windows_{{timestamp}}_v${var.version}"
  managed_image_resource_group_name = "gimgpocRG"
  os_type                           = "Windows"
  subscription_id                   = "${env("AZURE_SUBSCRIPTION_ID")}"
  tenant_id                         = "${env("AZURE_TENANT_ID")}"
  vm_size                           = "Standard_D2_v2"
  winrm_insecure                    = true
  winrm_timeout                     = "5m"
  winrm_use_ssl                     = true
  winrm_username                    = "packer"
}

build {

  hcp_packer_registry {
    bucket_name = "lr-pkr-az-win-gh-act-023"
    description = "Github Actions HCP Packer Terraform Cloud Run POC"

    bucket_labels = {
      "hashicorp-learn" = "learn-packer-github-actions",
    }
  }

  sources = ["source.azure-arm.windows-2016"]

  /*provisioner "powershell" {
    inline = ["Add-WindowsFeature Web-Server", "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }", "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }", "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit", "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"]
  }*/

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      iteration_id = packer.iterationID
    }
  }

}
