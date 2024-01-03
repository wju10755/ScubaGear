Write-Host -ForegroundColor Yellow "Loading CISA SCuBA Baseline Report Tool..."
$scubaDir = "C:\temp\scuba"
if (!(Test-Path $scubaDir)){
    New-Item -path "c:\temp\scuba"
} else {
    #Write-Host "Scuba directory already exists."
}

Invoke-WebRequest -uri "https://raw.githubusercontent.com/wju10755/ScubaGear/main/Start-Scuba.ps1" -OutFile "C:\temp\scuba\Start-Scuba.ps1"
$Scuba = "c:\temp\scuba\Start-Scuba.ps1"
$Process = Start-Process -FilePath powershell $Scuba -Wait
Remove-item -path "C:\temp\scuba\Start-Scuba.ps1"
