resource "null_resource" "certbot_config" {
  provisioner "remote-exec" {
    inline = [
      # Allow access to HTTP (port 80) from outside required for certbot
      "sudo ufw allow 80",
      # Obtain CA-signed certificate using certbot for irku.se
      "sudo certbot --apache --non-interactive --agree-tos --redirect --email mukesh.bciit@gmail.com -d irku.se",
      "sudo systemctl reload apache2",
      # Block access to HTTP (port 80) from outside using UFW after certbot setup
      "sudo ufw deny 80",
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
