variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. dev, prod)"
}

variable "region" {
  type        = string
  default     = "asia-east2"
  description = "GCP Region (Hong Kong)"
}

variable "network_id" {
  type        = string
  description = "VPC Network ID from networking module"
}

variable "tier" {
  type        = string
  default     = "db-custom-2-3840" # 2 vCPU, 3.75 GB RAM (Cost-effective for Dev)
  description = "Machine spec tier for Cloud SQL instance"
}

variable "availability_type" {
  type        = string
  default     = "ZONAL" # Single AZ for Dev cost savings ("REGIONAL" for Prod HA)
  description = "ZONAL or REGIONAL availability"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master SA password for SQL Server"
}
