variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (e.g. dev, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "name_suffix" {
  description = "Suffix for the repository name (e.g. nginx, rails)"
  type        = string
}
