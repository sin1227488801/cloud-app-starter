variable "project" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

# Minimal EC2 example to be added during iteration.
# Start with network-only, then add EC2.
