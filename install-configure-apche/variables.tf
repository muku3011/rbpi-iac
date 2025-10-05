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