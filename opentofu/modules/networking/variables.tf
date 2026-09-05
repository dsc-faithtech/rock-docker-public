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
  description = "GCP Region for Hong Kong"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Base CIDR range for the custom VPC"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for public resources in Hong Kong"
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR block for private Windows compute nodes in Hong Kong"
}

variable "db_subnet_cidr" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR block reserved for Cloud SQL instances in Hong Kong"
}
