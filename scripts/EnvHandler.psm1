# ==============================================================================
# EnvHandler.psm1 - Environment Variable Management Module
# ==============================================================================

function Initialize-Environment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptRoot
    )

    $EnvPath = Join-Path $ScriptRoot ".env"
    $EnvExamplePath = Join-Path $ScriptRoot ".env.example"

    # 1. Ensure .env exists
    if (Test-Path $EnvPath) {
        Write-Host ".env file found. Loading configuration..." -ForegroundColor Yellow
    } else {
        if (Test-Path $EnvExamplePath) {
            Copy-Item $EnvExamplePath $EnvPath
            Write-Host "Created .env from .env.example" -ForegroundColor Green
        } else {
            throw "[ERROR] Could not find .env.example in $ScriptRoot"
        }
    }

    # 2. Parse .env key-values into $env: scope
    Get-Content $EnvPath | Where-Object { $_ -match '^\s*[^#].*=' } | ForEach-Object {
        $name, $value = $_.Split('=', 2)
        $name = $name.Trim()
        $value = $value.Trim().Trim('"').Trim("'")
        [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::Process)
    }

    # 3. Validate & Apply Defaults
    if (-not $env:SQL_SA_PASSWORD) {
        throw "[ERROR] SQL_SA_PASSWORD is not set in .env."
    }
    if (-not $env:SQL_PORT) { $env:SQL_PORT = "1433" }
    if (-not $env:ROCK_HTTP_PORT) { $env:ROCK_HTTP_PORT = "9000" }

    Write-Host " [OK] Environment variables successfully initialized." -ForegroundColor Green
}

Export-ModuleMember -Function Initialize-Environment