# ==============================================================================
# DiskSpace.psm1 - Storage Pre-flight Validation Module
# ==============================================================================

function Test-DiskSpace {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$MinFreeGb = 30
    )

    # Identify Docker root drive (defaults to system drive C:)
    $DockerDrive = "C"
    $DockerInfo = docker info --format '{{.DockerRootDir}}' 2>$null
    if ($DockerInfo -and $DockerInfo -match '^([A-Za-z]):') {
        $DockerDrive = $Matches[1]
    }

    $DriveData = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='${DockerDrive}:'"
    $FreeGb = [math]::Round($DriveData.FreeSpace / 1GB, 2)

    Write-Host "[Pre-flight] Checking disk space on drive ${DockerDrive}:..." -ForegroundColor Cyan
    Write-Host "             Available: ${FreeGb} GB | Required: ${MinFreeGb} GB" -ForegroundColor Gray

    if ($FreeGb -lt $MinFreeGb) {
        Write-Host "------------------------------------------------------------" -ForegroundColor Red
        Write-Host "[ERROR] Insufficient disk space for Windows container extraction!" -ForegroundColor Red
        Write-Host "Drive ${DockerDrive}: has only ${FreeGb} GB free, but at least ${MinFreeGb} GB is required." -ForegroundColor Red
        Write-Host "Free up disk space or run: docker builder prune -a -f" -ForegroundColor Red
        Write-Host "------------------------------------------------------------" -ForegroundColor Red
        throw "Insufficient disk space on drive ${DockerDrive}: (${FreeGb} GB available, ${MinFreeGb} GB required)."
    }

    Write-Host " [OK] Sufficient disk space available." -ForegroundColor Green
}

Export-ModuleMember -Function Test-DiskSpace