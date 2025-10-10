resource "null_resource" "update_website" {
  provisioner "remote-exec" {
    inline = [
      # Remove old website content
      "sudo rm -rf /var/www/html",
      # Clone static website from GitHub
      "sudo git clone https://github.com/muku3011/website.git /var/www/html/",
      # Set correct permissions
      "sudo chown -R www-data:www-data /var/www/html"
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
