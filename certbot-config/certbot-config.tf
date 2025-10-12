# Obtain and configure TLS certificates with Certbot for an Apache-hosted site.
# This resource:
# - Temporarily opens HTTP (80) to allow HTTP-01 ACME validation
# - Runs certbot with the Apache plugin to issue and configure certificates
# - Reloads Apache to pick up the new certs and redirect rules
# - Closes HTTP (80) after issuance (HTTPS-only)
#
# Caution:
# - Ensure the domain DNS resolves to this Raspberry Pi before running certbot.
# - If HTTP must remain open (e.g., for other apps), remove the final "ufw deny 80" step.
resource "null_resource" "certbot_config" {
  provisioner "remote-exec" {
    inline = [
      # Allow inbound HTTP during validation
      "sudo ufw allow 80",

      # Issue certificate and configure Apache (non-interactive)
      # - Adjust domain and email as appropriate
      "sudo certbot --apache --non-interactive --agree-tos --redirect --email mukesh.bciit@gmail.com -d irku.se",

      # Reload Apache to apply changes
      "sudo systemctl reload apache2",

      # Close HTTP to enforce HTTPS-only (optional; remove if HTTP should stay open)
      "sudo ufw deny 80",
    ]

    # SSH connection to the Raspberry Pi
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
  description = "SSH username used to connect to the Raspberry Pi"
  type        = string
}

# Local filesystem path to the SSH private key used for authentication.
variable "raspberrypi_private_key" {
  description = "Path to SSH private key"
  type        = string
}
