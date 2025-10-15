# Infrastructure as Code for Raspberry Pi setup using Terraform/OpenTofu.
# This root module wires together submodules that:
# - install required packages
# - configure UFW firewall
# - deploy/update a website
# - configure Certbot for TLS certificates
#
# Inputs (variables):
# - raspberrypi_host: IP/hostname of the target Raspberry Pi
# - raspberrypi_user: SSH username to connect as
# - raspberrypi_private_key: path to the SSH private key used for auth
#
# Usage:
# 1) Set variables in terraform.tfvars or via CLI/environment.
# 2) terraform init
# 3) terraform apply
#
# Notes:
# - Relies on SSH connectivity from the machine running Terraform.
# - Ensure the private key path is accessible and permissions are correct.

terraform {
  # Declare required providers and their constraints.
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Configure providers used by modules/resources in this root module.
provider "local" {}

module "install_packages" {
  source                  = "./install-packages"
  raspberrypi_host        = var.raspberrypi_host
  raspberrypi_user        = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}

module "ufw_config" {
  source                  = "./config-ufw"
  raspberrypi_host        = var.raspberrypi_host
  raspberrypi_user        = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}

module "update_website" {
  source                  = "./update-website"
  raspberrypi_host        = var.raspberrypi_host
  raspberrypi_user        = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
  email_password          = var.email_password
  keystore_password       = var.keystore_password
}

module "certbot-config" {
  source                  = "./certbot-config"
  raspberrypi_host        = var.raspberrypi_host
  raspberrypi_user        = var.raspberrypi_user
  raspberrypi_private_key = var.raspberrypi_private_key
}

# Hostname or IP of the Raspberry Pi reachable over SSH.
variable "raspberrypi_host" {
  description = "IP address or hostname of the Raspberry Pi"
  type        = string
}

# SSH username used to connect to the Raspberry Pi.
variable "raspberrypi_user" {
  description = "SSH username for the Raspberry Pi"
  type        = string
}

# Local filesystem path to the SSH private key used for authentication.
variable "raspberrypi_private_key" {
  description = "Path to SSH private key"
  type        = string
}

# Add a variable for email password
variable "email_password" {
  description = "Email account password for SMTP"
  type        = string
  sensitive   = false # otherise information is not visible in logs
}

# Add a variable for keystore password
variable "keystore_password" {
  description = "Keystore password for backend application"
  type        = string
  sensitive   = false # otherise information is not visible in logs
}
