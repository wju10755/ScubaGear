Set-ExecutionPolicy -ExecutionPolicy Bypass -Force > $null
Clear-Host

function Print-Middle($Message, $Color = "White") {
    Write-Host (" " * [System.Math]::Floor(([System.Console]::BufferWidth / 2) - ($Message.Length / 2))) -NoNewline
    Write-Host -ForegroundColor $Color $Message
}

# Print Script Title
#################################
$Padding = ("=" * [System.Console]::BufferWidth)
Write-Host -ForegroundColor "Blue" `n$Padding `n -NoNewline
Print-Middle "CISA - Security Baseline Conformance Reports" "Blue"
Write-Host -ForegroundColor "Blue" $Padding;
Write-Host "`n"


# Define the URL for the latest release of ScubaGear
#$scubaGearUrl = "https://codeload.github.com/cisagov/ScubaGear/zip/refs/heads/main"
$scubaGearUrl = "https://codeload.github.com/wju10755/ScubaGear/zip/refs/heads/main"
# Define the URL for the OPA download
$opaUrl = "https://openpolicyagent.org/downloads/v0.60.0/opa_windows_amd64.exe"

# Define the path to the ScubaGear installation directory
$scubaDir = "C:\temp\scuba"
$scubafile = "$scubaDir\scuba.zip"
$setup = "$scubaDir\setup.ps1"
$opaFile = "$scubaDir\opa_windows_amd64.exe"

# Check if NuGet provider is available
if (-not (Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq 'NuGet' })) {
    # NuGet provider is not installed, proceed with installation
    try {
        # Install NuGet provider silently
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
        
    } catch {
        # Error handling
        Write-Host "Error occurred while installing NuGet package provider: $_"
    }
} else {
    # NuGet provider is already installed
    #Write-Host "NuGet package provider is already installed."
}


Start-Transcript -Path "c:\temp\scuba\scuba.log"

# Create the ScubaGear installation directory if it doesn't exist
if (-not (Test-Path $scubaDir)) {
    New-Item -ItemType Directory -Path $scubaDir | Out-Null
} else {
    #Write-Host "Scuba directory already exists"
}

# Set Working Directory
Set-Location $scubaDir


# Download the latest release of ScubaGear and extract it to the installation directory
if (-not (Test-Path $scubafile)) {
# Download the file
Write-Host "Downloading latest release of CISA Scuba (2,578,666 bytes)..." -NoNewline
Invoke-WebRequest -Uri $scubaGearUrl -OutFile $scubafile
Write-Host " done." -ForegroundColor Green
}

# Unpack ScubaGear and move to root of c:\temp\scuba\
if (-not (Test-Path $setup)) {
    Write-Host "Unpacking ScubaGear..." -NoNewline
    Expand-Archive -Path $scubafile -DestinationPath $scubaDir -Force
    Move-Item -Path "$scubaDir\ScubaGear-main\*" -Destination "c:\temp\scuba\" -Force
    Remove-Item "$scubaDir\ScubaGear-main"
    Write-Host " done." -ForegroundColor Green
}

# Download OPA and save it to the scuba directory
if (-not (Test-Path $opaFile)) {
    # Download the file
    Write-Host "Downloading Open Policy Agent (91,104,854 bytes)..." -NoNewline
    Invoke-WebRequest -Uri $opaUrl -OutFile $opaFile
    Write-Host " done." -ForegroundColor Green
    }

# Run module requirements setup
Write-Host "Starting module requirement check..."
& "$scubaDir\setup.ps1"
Write-Host "Module check complete."
#$RequiredModulesPath = Join-Path -Path $scubaDir -ChildPath "PowerShell\ScubaGear\RequiredVersions.ps1"
#f (Test-Path -Path $RequiredModulesPath) {
#  . $RequiredModulesPath
#}

#if (-not(Test-Path $RequiredModulesPath)) {
#    & "c:\temp\scuba\setup.ps1"
#    }


# Import the ScubaGear module
Write-Host "Invoking CISA Scuba Tool..."
Import-Module "$scubaDir\powershell\scubagear\ScubaGear.psd1"

# Run Invoke-SCuBA
Invoke-SCuBA

# Get the list of directories in the Scuba directory that include "M365BaselineConformance"
#$reportDirs = Get-ChildItem -Path "$scubaDir\M365BaselineConformance*" -Directory

# Sort the directories by creation time in descending order
#$sortedDirs = $reportDirs | Sort-Object -Property CreationTime -Descending

# Get the most recent directory
#$mostRecentDir = $sortedDirs[0]

# Save the path to the most recent directory as the $ScubaReport variable
#$ScubaReport = $mostRecentDir.FullName

# Launch SCuBA Report
#Invoke-Item "$ScubaReport\baselinereports.html"
Write-Host " "
Stop-Transcript
Write-Host " "
Write-Host " "
Read-Host -Prompt "Press Enter to Exit"