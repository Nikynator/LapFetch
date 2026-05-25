# ==============================================================================
# LapFetch - Multi-Language Support (DE / EN)
# ==============================================================================

# 1. Load Configuration
$ConfigPath = Join-Path $PSScriptRoot "config.json"
if (-not (Test-Path $ConfigPath)) {
    Write-Error "Configuration file config.json not found!"
    exit
}
$Config = Get-Content $ConfigPath | ConvertFrom-Json

# Create local target directory if it doesn't exist [cite: 6]
if (-not (Test-Path $Config.LocalTargetDir)) {
    New-Item -ItemType Directory -Path $Config.LocalTargetDir -Force | Out-Null
}

$ReportSuccess = @()
$ReportErrors = @()

# 2. Loop through target laptops
foreach ($Laptop in $Config.TargetLaptops) {
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Processing device: $Laptop" -ForegroundColor Cyan
    
    # 3. Check connectivity (Ping)
    if (-not (Test-Connection -ComputerName $Laptop -Count 1 -Quiet)) {
        $msg = "Device not reachable (Ping failed)."
        Write-Host "[ERROR] $msg" -ForegroundColor Red
        $ReportErrors += [PSCustomObject]@{ Laptop = $Laptop; Path = "N/A"; Error = $msg }
        continue 
    }

    # 4. Fetch Mode: Process paths (Supports both EN and DE paths from config) [cite: 6, 9]
    foreach ($RelativePath in $Config.SourcePaths) {
        $RemotePath = "\\$Laptop\$RelativePath"
        
        # Resolve wildcards (e.g., *.sb3) [cite: 4]
        try {
            # Standardizing path handling for special characters like 'Ö'
            $Items = Get-Item -Path $RemotePath -ErrorAction SilentlyContinue
        } catch {
            # If the path doesn't exist on this language layout, safely skip it 
            continue
        }

        # If no items match this specific path, move to the next path
        if (-not $Items) { continue }

        foreach ($Item in $Items) {
            $TargetName = $Item.Name
            $DestinationPath = Join-Path $Config.LocalTargetDir $TargetName

            # 5. Prevent overwriting duplicates [cite: 7]
            if (Test-Path $DestinationPath) {
                $TargetName = "${Laptop}_${TargetName}"
                $DestinationPath = Join-Path $Config.LocalTargetDir $TargetName
                Write-Host "File already exists. Renamed to: $TargetName" -ForegroundColor Yellow
            }

            # 6. Copy file/folder [cite: 6]
            try {
                Write-Host "Copying $($Item.FullName) to $DestinationPath..." -ForegroundColor White
                Copy-Item -Path $Item.FullName -Destination $DestinationPath -Recurse -Force -ErrorAction Stop
                
                # 7. Cleanup Mode: Delete source only if copy succeeded [cite: 8]
                Write-Host "Copy successful. Deleting source file..." -ForegroundColor Green
                Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction Stop
                
                $ReportSuccess += [PSCustomObject]@{ Laptop = $Laptop; File = $Item.Name; Status = "Successfully copied & deleted" }
            }
            catch {
                # Catch language-specific file locks or access errors 
                $msg = $_.Exception.Message
                Write-Host "[ERROR] $msg" -ForegroundColor Red
                $ReportErrors += [PSCustomObject]@{ Laptop = $Laptop; Path = $Item.FullName; Error = $msg }
            }
        }
    }
}

# ==============================================================================
# 8. Output Report [cite: 11]
# ==============================================================================
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "PROCESS FINISHED - SUMMARY" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

if ($ReportSuccess.Count -gt 0) {
    Write-Host "`nSuccessfully processed:" -ForegroundColor Green
    $ReportSuccess | Format-Table -AutoSize
}

if ($ReportErrors.Count -gt 0) {
    Write-Host "`nFailed / Warnings:" -ForegroundColor Red
    $ReportErrors | Format-Table -AutoSize
} else {
    Write-Host "`nNo errors occurred!" -ForegroundColor Green
}