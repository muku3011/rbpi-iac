resource "null_resource" "install-packages" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install -y ufw",
      "sudo apt install -y apache2",
      "sudo apt install -y git",
      "sudo apt install -y certbot python3-certbot-apache",
    ]

    connection {
      type        = "ssh"
      host        = var.raspberrypi_host
      user        = var.raspberrypi_user
      private_key = file(var.raspberrypi_private_key)
    }
  }
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