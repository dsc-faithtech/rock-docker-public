# Rock RMS Docker Environment

This repository provides an automated local development environment for Rock RMS using Windows Containers and a local SQL Server Express instance.

## 📽 Demo Video 📽
[![Cursor_and_Visual_Studio_Code_-_readme_md_-_rock-docker-public_-_Visual_Studio_Code_-_7_October_2022](https://user-images.githubusercontent.com/508468/196969810-1a0aa1b8-fb80-484a-aee6-312dba3cd2bf.png)](https://www.loom.com/share/73649b62851a4a21a28c59b69e3e68e3)

---

## Prerequisites

1. **Windows Containers Enabled:** Docker Desktop must be configured to use **Windows Containers** (right-click the Docker tray icon and select *Switch to Windows containers...*).
2. **Disk Space:** Ensure you have at least **30 GB of free space** on your Docker root drive (typically `C:`). Windows Server Core base layers require significant space for image extraction.
3. **Administrator Privileges:** Host SQL Server setup and firewall rule configuration require running PowerShell as Administrator.

---

## Quick Start (One-Line Execution)

Clone the repository, open PowerShell as **Administrator**, navigate to the `scripts` folder, and run:

```powershell
cd 'C:\Source\GitHub\rock-docker-public\scripts'; ./setup.ps1; Start-Process "http://localhost:9000/Start.aspx"
```
