variable "client_id" {
  type    = string
  default = "${env("AZURE_CLIENT_ID")}"
}

variable "client_secret" {
  type    = string
  default = "${env("AZURE_CLIENT_SECRET")}"
}

variable "subscription_id" {
  type    = string
  default = "${env("AZURE_SUBSCRIPTION_ID")}"
}

variable "tenant_id" {
  type    = string
  default = "${env("AZURE_TENANT_ID")}"
}
