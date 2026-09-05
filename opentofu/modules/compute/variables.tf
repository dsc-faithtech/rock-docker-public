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

variable "subnet_id" {
  type        = string
  description = "Subnet ID from networking module"
}

variable "machine_type" {
  type        = string
  default     = "n2-standard-4" # Minimum recommended for Windows IIS / Rock RMS
  description = "GCP Machine type for Windows instances"
}

variable "target_size" {
  type        = number
  default     = 2
  description = "Number of instances in the Managed Instance Group"
}