resource "null_resource" "config_ufw" {
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw",
      "sudo ufw --force disable",
      "sudo ufw default deny incoming",
      "sudo ufw default allow outgoing",
      "sudo ufw allow ssh",
      "sudo ufw allow 443",
      "sudo ufw --force enable"
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