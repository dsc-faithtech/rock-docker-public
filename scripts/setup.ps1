# cd 'C:\Source\GitHub\rock-docker-public\scripts'; ./demo.ps1

# ==============================================================================
# demo.ps1 - Orchestrator Script
# ==============================================================================

# 1. Import Modules
Import-Module (Join-Path $PSScriptRoot "DiskSpace.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "EnvHandler.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "HostSqlSetup.psm1") -Force

# 2. Pre-flight Checks & Environment Setup
try {
    Test-DiskSpace -MinFreeGb 30
    Initialize-Environment -ScriptRoot $PSScriptRoot
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 3. Host SQL Server Setup
if (-not (Get-Service "MSSQL`$SQLEXPRESS" -ErrorAction SilentlyContinue)) {
    try {
        $SecurePassword = ConvertTo-SecureString $env:SQL_SA_PASSWORD -AsPlainText -Force
        Install-HostSqlServer -SaPassword $SecurePassword -Port ([int]$env:SQL_PORT)
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host " [OK] Host SQL Server (SQLEXPRESS) is already installed." -ForegroundColor Green
}

# 4. Detect Container Engine
$Engine = $null
if (Get-Command podman-compose -ErrorAction SilentlyContinue) {
    $Engine = "podman-compose"
} elseif (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    $Engine = "docker-compose"
} else {
    Write-Error "[ERROR] Neither podman-compose nor docker-compose was found in PATH."
    exit 1
}

# 5. Build and Launch
Write-Host "[1/2] Using container engine: $Engine" -ForegroundColor Green
Write-Host "[2/2] Building and starting local services..." -ForegroundColor Cyan

$env:DOCKER_BUILDKIT = 0
$env:COMPOSE_DOCKER_CLI_BUILD = 0

& $Engine up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Error "[ERROR] $Engine build or up failed. Please check the logs above."
    exit 1
}

$HttpPort = $env:ROCK_HTTP_PORT
$SqlPort = $env:SQL_PORT
$SqlPassword = $env:SQL_SA_PASSWORD

Write-Host "========================================" -ForegroundColor Green
Write-Host " SUCCESS! Rock RMS Demo is running.     " -ForegroundColor Green
Write-Host " Access Web UI : http://localhost:$HttpPort/Start.aspx" -ForegroundColor Green
Write-Host " SQL Server    : localhost:$SqlPort (sa / $SqlPassword)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green