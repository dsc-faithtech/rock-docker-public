# OpenTofu Infrastructure as Code (GCP - Hong Kong)

This directory contains OpenTofu (`.tf`) code organized into reusable modules and isolated environment stacks to provision an enterprise production environment for Rock RMS on **Google Cloud Platform (GCP)** targeting the **Hong Kong region (`asia-east2`)**.

---

## Directory Layout

```text
opentofu/
├── modules/
│   ├── networking/   # VPC, custom subnets, Cloud NAT, and firewall rules
│   ├── database/     # Cloud SQL for SQL Server Enterprise/Standard
│   └── compute/      # Windows Compute Engine MIGs, Artifact Registry & HTTPS Load Balancer
├── environments/
│   ├── dev/          # Staging stack (Single-zone DB, minimal instance sizing)
│   └── prod/         # Production stack (Regional HA DB, Multi-zone MIGs, Cloud Armor)
└── README.md

```

---

## Module Breakdown

* **`modules/networking/`**: Manages the custom VPC, private/public subnets in `asia-east2`, Cloud NAT (enabling Windows instances to retrieve OS updates without public IPs), and VPC firewall rules.
* **`modules/database/`**: Provisions Google Cloud SQL for SQL Server with regional High Availability (HA) across Hong Kong zones (`asia-east2-a`, `asia-east2-b`).
* **`modules/compute/`**: Configures the Windows Compute Engine Managed Instance Group (MIG) running IIS/Rock RMS, Google Cloud External HTTPS Load Balancing, and Artifact Registry for Windows container images.

---

## Production Architecture Diagram

```text
                     [ User Requests ]
                            │
                            ▼
            [ GCP External HTTPS Load Balancer ]
             (HTTPS / TLS Termination Port 443)
                            │
            ┌───────────────┴───────────────┐
            ▼                               ▼
  [ Compute Engine Instance ]    [ Compute Engine Instance ]
   (Windows Server / IIS)         (Windows Server / IIS)
            └───────────────┬───────────────┘
                            │
                            ▼
           [ Cloud SQL for SQL Server Enterprise ]
                 (Regional HA - Hong Kong)

```

---

## Local Dev vs. Production Architecture

| Feature | Local Development (`setup.ps1`) | Production (OpenTofu) |
| --- | --- | --- |
| **Cloud Provider** | Local Workstation | Google Cloud Platform (`asia-east2`) |
| **Operating System** | Windows 10/11 Workstation | Windows Server 2022 Core |
| **SQL Engine** | Local SQL Express (Single Host) | Cloud SQL for SQL Server (Regional HA) |
| **Web Host** | Single local Docker container | Regional Managed Instance Group (MIG) |
| **TLS / SSL** | Plain HTTP (`http://localhost:9000`) | Managed SSL Certificates via Cloud Load Balancer |
| **File Storage** | Local Disk Mounts | Google Cloud Storage Buckets |

---

## Prerequisites

1. **Install OpenTofu:**
```powershell
winget install opentofu.opentofu

```


2. **Google Cloud SDK Configured:** Authenticate and set your active project:
```powershell
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_GCP_PROJECT_ID

```



---

## Quick Start Deployment

### 1. Select Environment & Set Variables

Navigate to the target environment directory (`environments/dev` or `environments/prod`):

```powershell
cd environments/dev

```

Copy the example variables file and configure your credentials:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars

```

### 2. Initialize OpenTofu

Initialize modules, download the Google Cloud (`hashicorp/google`) provider, and set up state management:

```powershell
tofu init

```

### 3. Review Execution Plan

Generate an execution plan to inspect infrastructure changes targeting `asia-east2`:

```powershell
tofu plan -out=env.tfplan

```

### 4. Deploy Infrastructure

Apply the execution plan:

```powershell
tofu apply "env.tfplan"

```

---

## Post-Deployment Workflow

1. **Push Windows Container Image:** Authenticate Docker against GCP Artifact Registry, tag your Rock RMS Windows container image, and push:
```powershell
gcloud auth configure-docker asia-east2-docker.pkg.dev
docker tag rock-web asia-east2-docker.pkg.dev/YOUR_PROJECT_ID/rockrms-dev-repo/rock-web:v1
docker push asia-east2-docker.pkg.dev/YOUR_PROJECT_ID/rockrms-dev-repo/rock-web:v1

```


2. **Migrate Database:** Import your local SQL Server `.bak` database file into the provisioned Google Cloud SQL instance using Google Cloud Storage buckets.
3. **Configure DNS:** Point your domain's `A` record (e.g., `rock.yourchurch.org`) to the Google External HTTPS Load Balancer IP output (`load_balancer_ip`).

---

## Clean Up

To tear down resources in the currently active environment:

```powershell
tofu destroy

```
