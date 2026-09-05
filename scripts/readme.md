# Setup Automated Workflow

## What the Setup Automated Workflow Does

The `setup.ps1` script automatically handles the entire end-to-end environment setup:

1. **Pre-flight Storage Validation (`DiskSpace.psm1`)**  
   Checks that your Docker root drive has at least 30 GB of free space to prevent layer extraction crashes. Fails fast if space is insufficient.
2. **Environment Configuration (`EnvHandler.psm1`)**  
   Creates a local `.env` file from `.env.example` if one does not exist and loads environment variables into process memory.
3. **Host SQL Server Provisioning (`HostSqlSetup.psm1`)**  
   Detects or installs SQL Server Express, enables TCP/IP protocol support on port `1433`, configures Mixed Mode Authentication, and sets up local firewall rules.
4. **Container Build & Orchestration**  
   Detects `podman-compose` or `docker-compose`, builds the Rock RMS web container, and starts the containerized service stack.

---

## Configuration Options

You can customize port bindings and passwords by editing the `.env` file generated in the `scripts/` directory:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `SQL_SA_PASSWORD` | `Password1!` | System Administrator password for SQL Server |
| `SQL_PORT` | `1433` | Host port mapped for SQL Server communication |
| `ROCK_HTTP_PORT` | `9000` | Host port mapped to the Rock RMS IIS site |

---

## Accessing Your Environment

Once the script completes successfully:

* **Rock RMS Setup Wizard:** `http://localhost:9000/Start.aspx`
* **Database Connection:** `localhost:1433`
  * **Authentication:** SQL Server Authentication
  * **Login:** `sa`
  * **Password:** *(Defined in `.env`)*

---

## Useful Commands

* **Stop the Environment:**

  ```powershell
  docker-compose down
  ```

* **Free Docker Build Cache (if running low on disk space):**

   ```powershell
   docker builder prune -a -f
   ```
