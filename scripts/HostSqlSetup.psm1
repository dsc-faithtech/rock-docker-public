# ==============================================================================
# HostSqlSetup.psm1 - Host SQL Server Setup Module
# ==============================================================================

function Install-HostSqlServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]$SaPassword,

        [Parameter()]
        [int]$Port = 1433
    )

    Write-Host "[1/5] Checking Administrator privileges..." -ForegroundColor Cyan
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        throw "[ERROR] Installing host SQL Server requires Administrator privileges. Please re-run PowerShell as Administrator."
    }

    # 1. Install Chocolatey if missing
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        $env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"
    }

    # 2. Install SQL Server Express
    Write-Host "[2/5] Installing SQL Server Express..." -ForegroundColor Cyan
    choco install sql-server-express -y --no-progress

    # 3. Enable Mixed Mode Auth & Set SA Password
    Write-Host "[3/5] Configuring SQL Authentication..." -ForegroundColor Cyan
    $serviceName = "MSSQL`$SQLEXPRESS"
    
    while (-not (Get-Service $serviceName -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 2
    }

    $regPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQLServer"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "LoginMode" -Value 2
    }

    Restart-Service -Name $serviceName -Force

    # Convert SecureString for sqlcmd execution
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SaPassword)
    $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    try {
        $sqlCmd = "ALTER LOGIN sa WITH PASSWORD = '$PlainPassword'; ALTER LOGIN sa ENABLE;"
        sqlcmd -S ".\SQLEXPRESS" -Q $sqlCmd
    } finally {
        # Free memory immediately
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }

    # 4. Enable TCP/IP Protocol
    Write-Host "[4/5] Enabling TCP/IP on Port $Port..." -ForegroundColor Cyan
    $tcpRegPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
    if (Test-Path $tcpRegPath) {
        Set-ItemProperty -Path $tcpRegPath -Name "TcpPort" -Value $Port
        Set-ItemProperty -Path $tcpRegPath -Name "TcpDynamicPorts" -Value ""
    }

    Restart-Service -Name $serviceName -Force

    # 5. Firewall Rule
    Write-Host "[5/5] Configuring Firewall Rule..." -ForegroundColor Cyan
    $ruleName = "RockRMS-SqlServer-$Port"
    if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow | Out-Null
    }

    Write-Host " [OK] Host SQL Server successfully configured!" -ForegroundColor Green
}

Export-ModuleMember -Function Install-HostSqlServer