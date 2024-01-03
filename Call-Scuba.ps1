Write-Host -ForegroundColor Yellow "Loading CISA SCuBA Baseline Report Tool..."
Invoke-WebRequest -uri "https://raw.githubusercontent.com/wju10755/Mits/main/Start-Scuba.ps1" -OutFile "C:\temp\Start-Scuba.ps1"
$BreachWatch = "c:\temp\Start-Scuba.ps1"
$Process = Start-Process -FilePath powershell $BreachWatch -Wait
Remove-item -path C:\temp\Start-Scuba.ps1Install-Module -Name Microsoft.GraphGet-AzureADUser -All $true | Where-Object { $_.AssignedLicenses.Count -eq 0 } | Select-Object DisplayName, UserPrincipalName


$users = Get-AzureADUser -All $true | Where-Object { $_.AssignedLicenses.Count -eq 0 }
$group = Get-AzureADGroup -Filter "DisplayName eq 'Terminated Users'"

foreach ($user in $users) {
    Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $user.ObjectId
}

