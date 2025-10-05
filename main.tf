terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "local" {}

module "system_update" {
  source                 = "./system-update"
  raspberrypi_host       = var.raspberrypi_host
  raspberrypi_user       = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}

module "ufw" {
  source                 = "./ufw"
  raspberrypi_host       = var.raspberrypi_host
  raspberrypi_user       = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}

module "install_packages" {
  source                 = "./install-configure-apche"
  raspberrypi_host       = var.raspberrypi_host
  raspberrypi_user       = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}