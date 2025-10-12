# Provision base system packages and tooling on the Raspberry Pi over SSH.
# This resource performs:
# - System update/upgrade
# - Installation of UFW, Apache, Git, Certbot (with Apache plugin)
# - Installation of OpenJDK 25
# - Installation of Apache Maven 3.9.11 under /opt and PATH setup for the session
#
# Notes:
# - PATH and M2_HOME exports affect only the provisioner session; consider persisting them in shell profile if needed.
# - Ensure the SSH key path is valid on the machine running Terraform.
resource "null_resource" "install-packages" {
  provisioner "remote-exec" {
    inline = [
      # Update and upgrade base system packages
      "sudo apt update -y",
      "sudo apt upgrade -y",

      # Core tools and services
      "sudo apt install -y ufw",
      "sudo apt install -y apache2",
      "sudo apt install -y git",

      # Certbot for TLS certificates via Apache
      "sudo apt install -y certbot python3-certbot-apache",

      # Java runtime/tooling for backend services
      "sudo apt install -y openjdk-25-jdk",

      # Install Maven 3.9.11 under /opt
      "sudo rm-rf /opt/apache-maven-3.9.11",
      "wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz",
      "tar xzvf apache-maven-3.9.11-bin.tar.gz",
      "sudo mv apache-maven-3.9.11 /opt/",
      "rm -rf apache-maven-3.9.11-bin.tar.gz apache-maven-3.9.11",
      "export M2_HOME=/opt/apache-maven-3.9.11",
      "export PATH=$M2_HOME/bin:$PATH"
    ]

    # SSH connection details for the Raspberry Pi
    connection {
      type        = "ssh"
      host        = var.raspberrypi_host
      user        = var.raspberrypi_user
      private_key = file(var.raspberrypi_private_key)
    }
  }
}

# Input variables

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