variable "project" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

# Minimal NIC + Linux VM example to be added during iteration.
# Start with network-only if you're brand-new, then add VM.
