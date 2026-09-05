variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  default     = "asia-east2"
  description = "GCP Region for Hong Kong"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master SA password for SQL Server"
}