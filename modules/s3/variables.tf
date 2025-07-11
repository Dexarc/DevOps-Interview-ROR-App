// variables.tf
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "myproject"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
