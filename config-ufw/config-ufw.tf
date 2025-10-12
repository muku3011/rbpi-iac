# Configure UFW (Uncomplicated Firewall) on the Raspberry Pi via SSH.
# This resource:
# - Disables IPv6 in UFW config (optional hardening; adjust if IPv6 is required)
# - Sets default policies: deny incoming, allow outgoing
# - Allows SSH (22) and HTTPS (443)
# - Enables UFW non-interactively
#
# Caution:
# - Disabling IPv6 may impact services using IPv6. Remove the sed line if IPv6 is needed.
# - Ensure SSH access is allowed before enabling UFW to avoid locking yourself out.
resource "null_resource" "config_ufw" {
  provisioner "remote-exec" {
    inline = [
      # Disable IPv6 in UFW config (comment/remove if IPv6 should remain enabled)
      "sudo sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw",

      # Reset and set baseline policies
      "sudo ufw --force disable",
      "sudo ufw default deny incoming",
      "sudo ufw default allow outgoing",

      # Allow required services
      # Also make sure below ports are exposed in Router Firewall to allow access from internet
      "sudo ufw allow ssh",
      "sudo ufw allow 443",
      "sudo ufw allow 8700",

      # Enable UFW without interactive prompt
      "sudo ufw --force enable"
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
