terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "local" {}

module "install_packages" {
  source                 = "./install-packages"
  raspberrypi_host       = var.raspberrypi_host
  raspberrypi_user       = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}

module "ufw_config" {
  source                 = "./config-ufw"
  raspberrypi_host       = var.raspberrypi_host
  raspberrypi_user       = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}

module "update_website" {
  source                 = "./update-webiste"
  raspberrypi_host       = var.raspberrypi_host
  raspberrypi_user       = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}

module "certbot-config" {
  source                 = "./certbot-config"
  raspberrypi_host       = var.raspberrypi_host
  raspberrypi_user       = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}

variable "raspberrypi_host" {
  description = "IP address or hostname of the Raspberry Pi"
  type        = string
}

variable "raspberrypi_user" {
  description = "SSH username for the Raspberry Pi"
  type        = string
}

variable "raspberrypi_private_key" {
  description = "Path to SSH private key"
  type        = string
}