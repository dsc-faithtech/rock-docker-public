terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Networking Layer
module "networking" {
  source              = "../../modules/networking"
  project_id          = var.project_id
  environment         = "dev"
  region              = var.region
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  db_subnet_cidr      = "10.0.3.0/24"
}

# 2. Database Layer
module "database" {
  source            = "../../modules/database"
  project_id        = var.project_id
  environment       = "dev"
  region            = var.region
  network_id        = module.networking.network_id
  tier              = "db-custom-2-3840" # Cost-effective dev spec
  availability_type = "ZONAL"           # Single-AZ for dev
  db_password       = var.db_password
}

# 3. Compute & Load Balancing Layer
module "compute" {
  source       = "../../modules/compute"
  project_id   = var.project_id
  environment  = "dev"
  region       = var.region
  network_id   = module.networking.network_id
  subnet_id    = module.networking.private_subnet_id
  machine_type = "n2-standard-4"
  target_size  = 1 # 1 instance for dev testing
}