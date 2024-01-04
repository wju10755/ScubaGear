$ErrorActionPreference = "SilentlyContinue"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force > $null
Write-Host -ForegroundColor Yellow "Loading CISA SCuBA Baseline Report Tool..."
$scubaDir = "C:\temp\scuba"
if (!(Test-Path $scubaDir)){
    New-Item -ItemType Directory -Path $scubaDir | Out-Null
} else {
    Write-Host "Scuba directory already exists."
}

Invoke-WebRequest -uri "https://raw.githubusercontent.com/wju10755/ScubaGear/main/Start-Scuba-v2.ps1" -OutFile "C:\temp\scuba\Start-Scuba.ps1"
$Scuba = "c:\temp\scuba\Start-Scuba.ps1"
$Process = Start-Process -FilePath powershell $Scuba -Wait
Start-Sleep -Seconds 3
Remove-item -path $Scuba
