Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force > $null
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

Start-Transcript -Path "c:\temp\scuba.log"

# Define the URL for the latest release of ScubaGear
#$scubaGearUrl = "https://codeload.github.com/cisagov/ScubaGear/zip/refs/heads/main"
$scubaGearUrl = "https://codeload.github.com/wju10755/ScubaGear/zip/refs/heads/main"
# Define the URL for the OPA download
$opaUrl = "https://openpolicyagent.org/downloads/v0.60.0/opa_windows_amd64.exe"

# Define the path to the ScubaGear installation directory
$tmp = "c:\temp"
$scubaDir = "C:\temp\scuba"
$scubafile = "$tmp\scuba.zip"
$setup = "c:\temp\scuba\setup.ps1"
$opaFile = "$scubaDir\opa_windows_amd64.exe"

# Check if the MicrosoftTeams module is installed
if (-not (Get-Module -ListAvailable -Name MicrosoftTeams)) {
    # If not installed, install the MicrosoftTeams module
    Write-Host "Microsoft Teams module not found. Installing..."
    Install-Module -Name MicrosoftTeams -Force -AllowClobber
    Import-Module MicrosoftTeams
} else {
    # If installed, display a message
    Write-Host "Microsoft Teams module is already installed."
}

# Check if the Microsoft Sharepoint Powershell module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell)) {
    # If not installed, install the Microsoft.Online.SharePoint.PowerShell module
    Write-Host "Microsoft Online SharePoint PowerShell module not found. Installing..."
    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber
    Import-Module Microsoft.Online.SharePoint.Powershell
} else {
    # If installed, display a message
    Write-Host "Microsoft Online SharePoint PowerShell module is already installed."
}


# Check if the Microsoft PnP.PowerShell module is installed
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    # If not installed, install the Microsoft.Online.SharePoint.PowerShell module
    Write-Host "Microsoft PnP.PowerShell module not found. Installing..."
    Install-Module -Name PnP.PowerShell -Scope CurrentUser
    Import-Module PnP.PowerShell
} else {
    # If installed, display a message
    Write-Host "Microsoft PnP.PowerShell module is already installed."
}


# Create the ScubaGear installation directory if it doesn't exist
if (-not (Test-Path $scubaDir)) {
    New-Item -ItemType Directory -Path $scubaDir | Out-Null
} else {
    Write-Host "Scuba directory already exists"
}

# Set Working Directory
Set-Location $scubaDir

# Download the latest release of ScubaGear and extract it to the installation directory
if (!(Test-Path $scubafile)) {
    Write-Host "Downloading latest CISA ScubaGear release..." -NoNewline
    Invoke-WebRequest -Uri $scubaGearUrl -OutFile "c:\temp\scuba.zip"
    Write-Host " done." -ForegroundColor Green
} else {
    Write-Host "Existing scuba.zip download found"
}

if (-not (Test-Path $setup)) {
    Write-Host "Unpacking ScubaGear..." -NoNewline
    Expand-Archive -Path $scubafile -DestinationPath $scubaDir -Force
    Move-Item -Path "$scubaDir\ScubaGear-main\*" -Destination "c:\temp\scuba\" -Force
    Write-Host " done." -ForegroundColor Green
    Remove-Item "$scubaDir\ScubaGear-main"
}
# Download OPA and save it to the installation directory
if (-not(Test-Path $opaFile)) {
    Write-Host "Downloading Open Policy Agent..." -NoNewline
    Invoke-WebRequest -Uri $opaUrl -OutFile "$scubaDir\opa_windows_amd64.exe"
    Write-Host " done." -ForegroundColor Green
} else {
    Write-Host "Existing Open Policy Agent executable found."
}

$RequiredModulesPath = Join-Path -Path $scubaDir -ChildPath "PowerShell\ScubaGear\RequiredVersions.ps1"
if (Test-Path -Path $RequiredModulesPath) {
  . $RequiredModulesPath
}

if (-not(Test-Path $RequiredModulesPath)) {
    & "c:\temp\scuba\setup.ps1"
    }




# Import the ScubaGear module
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

Stop-Transcript

Read-Host -Prompt "Press Enter to Exit"