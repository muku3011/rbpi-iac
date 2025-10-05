resource "null_resource" "install_configure_apche" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt install -y apache2 git certbot python3-certbot-apache",
      # Clone or update static website from git
      "if [ -d /var/www/html/.git ]; then sudo git -C /var/www/html pull; else sudo rm -rf /var/www/html/* && sudo git clone https://github.com/yourusername/your-static-website.git /var/www/html; fi",
      # Obtain CA-signed certificate using certbot (replace example.com with your domain)
      "sudo certbot --apache --non-interactive --agree-tos --redirect --email mukesh.bciit@gmail.com -d irku.se",
      "sudo systemctl reload apache2"
    ]

    connection {
      type        = "ssh"
      host        = var.raspberrypi_host
      user        = var.raspberrypi_user
      private_key = file(var.raspberrypi_private_key)
    }
  }
}