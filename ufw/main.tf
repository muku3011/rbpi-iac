resource "null_resource" "ufw_config" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt install -y ufw",
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