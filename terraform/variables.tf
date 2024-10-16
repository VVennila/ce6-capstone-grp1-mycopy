# variables.tf
variable "env" {
  description = "The environment for which the state file will be stored (e.g., dev, prod)"
  type        = string
}
