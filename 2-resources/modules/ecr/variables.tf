variable "prefix" {}
variable "force_delete" {
  description = "Force delete repository (useful for development/testing)"
  type        = bool
  default     = false
}
variable "account_id" {}