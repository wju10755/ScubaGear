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

# Create the ScubaGear installation directory if it doesn't exist
if (-not (Test-Path $scubaDir)) {
    New-Item -ItemType Directory -Path $scubaDir | Out-Null
} else {
    Write-Host "Scuba directory already exists"
}

Start-Transcript -Path "c:\temp\scuba\scuba.log"

# Set Working Directory
Set-Location $scubaDir

# Download the latest release of ScubaGear and extract it to the installation directory
if (-not (Test-Path $scubafile)) {
    Write-Host "Downloading latest CISA ScubaGear release..." -NoNewline
    Invoke-WebRequest -Uri $scubaGearUrl -OutFile $scubafile

    # Expected hash and size for validation
    $expectedHash = "003EB1B6B74AD0E94BC7676F8F8891F523A6BF04AD502B351B2A5E76E0835135"
    $expectedSize = 2578494

    # Calculate actual hash and size of the downloaded file
    $actualHash = (Get-FileHash $scubafile -Algorithm SHA256).Hash.ToUpper()
    $actualSize = (Get-Item $scubafile).Length

    # Validate the downloaded file
    if ($expectedHash -eq $actualHash -and $expectedSize -eq $actualSize) {
        Write-Host " done." -ForegroundColor Green
    } else {
        Write-Error "Download failed. The downloaded file hash or size does not match the expected values."
        # Optionally, you can add a command to remove the incorrectly downloaded file
         Remove-Item $scubafile -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "Scuba.zip file already exists." -ForegroundColor Yellow
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
    Write-Host "Downloading Open Policy Agent..." -NoNewline
    Invoke-WebRequest -Uri $opaUrl -OutFile $opaFile

    # Expected hash and size for validation
    $expectedHash = "8E20B4FCD6B8094BE186D8C9EC5596477FB7CB689B340D285865CB716C3C8EA7"
    $expectedSize = 91104854

    # Calculate actual hash and size of the downloaded file
    $actualHash = (Get-FileHash $opaFile -Algorithm SHA256).Hash.ToUpper()
    $actualSize = (Get-Item $opaFile).Length

    # Validate the downloaded file
    if ($expectedHash -eq $actualHash -and $expectedSize -eq $actualSize) {
        Write-Host " done." -ForegroundColor Green
    } else {
        Write-Error "Download failed. The downloaded file hash or size does not match the expected values."
        # Optionally, you can add a command to remove the incorrectly downloaded file
         Remove-Item $opaFile -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "OPA file already exists." -ForegroundColor Yellow
}

# Run module requirements setup
& "$scubaDir\setup.ps1"

#$RequiredModulesPath = Join-Path -Path $scubaDir -ChildPath "PowerShell\ScubaGear\RequiredVersions.ps1"
#f (Test-Path -Path $RequiredModulesPath) {
#  . $RequiredModulesPath
#}

#if (-not(Test-Path $RequiredModulesPath)) {
#    & "c:\temp\scuba\setup.ps1"
#    }


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
Write-Host " "
Stop-Transcript
Write-Host " "
Write-Host " "
Read-Host -Prompt "Press Enter to Exit"