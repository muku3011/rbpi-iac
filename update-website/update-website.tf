# This module updates both the static frontend (Apache-served) and the Java backend on the Raspberry Pi.
# It connects over SSH using provided variables and performs idempotent-ish steps to refresh content and restart services.

resource "null_resource" "update_website" {
  # First remote-exec: refresh Apache-served static site
  provisioner "remote-exec" {
    inline = [
      # Remove old website content to ensure a clean clone
      "sudo rm -rf /var/www/html",
      # Clone static website from GitHub into Apache's document root
      "sudo git clone https://github.com/muku3011/website.git /var/www/html/",
      # Fix ownership so Apache (www-data) can serve files correctly
      "sudo chown -R www-data:www-data /var/www/html",
      # Reload Apache to pick up any config/content changes
      "sudo systemctl reload apache2",
    ]

    # SSH connection configuration for the Raspberry Pi
    connection {
      type        = "ssh"
      host        = var.raspberrypi_host
      user        = var.raspberrypi_user
      private_key = file(var.raspberrypi_private_key)
    }
  }

  # Second remote-exec: build and (re)start the Java backend service
  provisioner "remote-exec" {
    inline = [
      # Ensure Maven is available in the PATH for this session
      "export M2_HOME=/opt/apache-maven-3.9.11",
      "export PATH=$M2_HOME/bin:$PATH",
      "echo \"Maven configured: $(mvn -v | head -n1 || echo mvn not found)\"",

      # Stop previously running backend process if PID file exists and process is alive
      # - If PID cannot be read, continue without failing
      "pid=$(cat /home/rbpi/website-backend-manage/website-backend.pid 2>/dev/null || true); [ -n $pid ] && kill -9 $pid 2>/dev/null || true",

      # Clean old backend workspace to avoid stale artifacts
      "rm -rf /home/rbpi/website-backend",
      "echo \"Workspace cleaned: /home/rbpi/website-backend\"",

      # Ensure directories for runtime artifacts (PID, DB, logs) exist
      "mkdir -p /home/rbpi/website-backend-manage",
      "echo \"Ensured manage dir exists: /home/rbpi/website-backend-manage\"",

      # Fetch backend source code
      "git clone https://github.com/muku3011/website-backend.git /home/rbpi/website-backend/",
      "echo \"Git clone completed to /home/rbpi/website-backend\"",

      # Build backend with Maven (skip tests for faster deploy; -q quiet, -e print stack traces on errors)
      "cd /home/rbpi/website-backend/",
      "echo \"Entered repo dir: $(pwd)\"",
      "mvn -q -e -DskipTests clean package",
      "echo \"Maven build exit code: $?; artifact present: $(ls target/*.jar 2>/dev/null | wc -l)\"",

      # Configure SQLite DB path expected by the application
      "export SQLITE_PATH=/home/rbpi/website-backend-manage/blog.db",
      "echo \"SQLITE_PATH set to $SQLITE_PATH\"",

      "export SSL_KEY_STORE=/home/rbpi/website-backend-manage/keystore.p12",
      "export SSL_KEY_STORE_TYPE=PKCS12",
      "export SSL_KEY_STORE_PASSWORD=RaspBerryPi@150",
      "export SSL_KEY_ALIAS=website-backend",

      "rm -rf /home/rbpi/website-backend-manage/keystore.p12",
      "echo \"Old keystore removed (if existed)\"",
      "sudo openssl pkcs12 -export -out /home/rbpi/website-backend-manage/keystore.p12 -inkey /etc/letsencrypt/live/irku.se/privkey.pem -in /etc/letsencrypt/live/irku.se/cert.pem -certfile /etc/letsencrypt/live/irku.se/chain.pem -name $SSL_KEY_ALIAS -password pass:$SSL_KEY_STORE_PASSWORD",
      "echo \"Keystore created at $SSL_KEY_STORE\"",

      "sudo chmod 777 /home/rbpi/website-backend-manage/keystore.p12",

      # Launch the backend in the background and redirect logs
      "nohup java -jar /home/rbpi/website-backend/target/website-backend.jar > /home/rbpi/website-backend-manage/website-backend.log 2>&1 &",
      "echo \"Backend started; nohup exit code: $?\"",

      # Persist new PID for future restarts
      "echo $! > /home/rbpi/website-backend-manage/website-backend.pid",
      "echo \"New backend PID: $(cat /home/rbpi/website-backend-manage/website-backend.pid 2>/dev/null || echo unknown)\"",
    ]

    # SSH connection configuration for the Raspberry Pi
    connection {
      type        = "ssh"
      host        = var.raspberrypi_host
      user        = var.raspberrypi_user
      private_key = file(var.raspberrypi_private_key)
    }
  }
}

# Input variables required by this module

variable "raspberrypi_host" {
  description = "IP address or hostname of the Raspberry Pi used for SSH connections."
  type        = string
}

variable "raspberrypi_user" {
  description = "SSH username used to connect to the Raspberry Pi."
  type        = string
}

variable "raspberrypi_private_key" {
  description = "Path to the SSH private key file used for authentication."
  type        = string
}