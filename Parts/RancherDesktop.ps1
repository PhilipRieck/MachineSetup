Import-Module "$PSScriptRoot\..\Modules\Reboots.psm1"
Import-Module "$PSScriptRoot\..\Modules\Packages.psm1"

$minimumVersion = [semver]"1.10.0"

#Rancher desktop requires WSL
#Install WSL if required
$wslState = (Get-WindowsOptionalFeature -FeatureName "Microsoft-Windows-Subsystem-Linux" -Online | Select-Object -ExpandProperty State)
if($wslState -ne "Enabled"){
    Write-Host "WSL not installed. Enabling WSL (will require a reboot)"
    wsl --install --no-launch
    SetRebootRequired
    return
} else {
    Write-Host "WSL already enabled."
    $packageResult = EnsureWingetPackage "suse.RancherDesktop" "1.10.0"
}

