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
  default = "1.1.3"
}

source "azure-arm" "cis-win-2016-stig" {
  azure_tags = {
    dept = "System Engineering"
    task = "Windows VM Hardend Image deployment"
  }

  plan_info {
    plan_name      = "cis-win-2016-stig"
    plan_product   = "cis-win-2016-stig"
    plan_publisher = "center-for-internet-security-inc"
  }

  build_resource_group_name         = "myResourceGroup"
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  communicator                      = "winrm"
  image_offer                       = "cis-win-2016-stig"
  image_publisher                   = "center-for-internet-security-inc"
  image_sku                         = "cis-win-2016-stig"
  managed_image_name                = "packer_Azure_CIS_Windows_2019{{timestamp}}_v${var.version}"
  managed_image_resource_group_name = "myResourceGroup"
  os_type                           = "Windows"
  subscription_id                   = "${var.subscription_id}"
  tenant_id                         = "${var.tenant_id}"
  vm_size                           = "Standard_DS2_v2"
  winrm_insecure                    = true
  winrm_timeout                     = "5m"
  winrm_use_ssl                     = true
  winrm_username                    = "packer"
}

build {

  hcp_packer_registry {
    bucket_name = "lr-pkr-az-hrd-win-2016-gh-act-02"
    description = "Github Actions HCP Packer Hardened Win 2019 POC"

    bucket_labels = {
      "hashicorp-learn" = "Github Actions HCP Packer Hardened Win 2016 POC",
    }
  }

  sources = ["source.azure-arm.cis-win-2016-stig"]

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
