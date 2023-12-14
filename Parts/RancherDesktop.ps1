Import-Module "$PSScriptRoot\..\Modules\Reboots.psm1"
Import-Module "$PSScriptRoot\..\Modules\Packages.psm1"

$minimumVersion = [semver]"1.10.0"


$hvState = (Get-WindowsOptionalFeature -FeatureName "Microsoft-Hyper-V" -Online | Select-Object -ExpandProperty State)
if($hvState -ne "Enabled"){
    Write-Host "`tHyper-V not installed. Enabling Hyper-V (will require a reboot)"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
    bcdedit /set hypervisorlaunchtype auto
    SetRebootRequired
    return
} else {
    Write-Host "`tHyper-V already enabled."
}

#Rancher desktop requires WSL
#Install WSL if required
$wslState = (Get-WindowsOptionalFeature -FeatureName "Microsoft-Windows-Subsystem-Linux" -Online | Select-Object -ExpandProperty State)
if($wslState -ne "Enabled"){
    Write-Host "`tWSL not installed. Enabling WSL (may require a reboot)"
    wsl --install --no-launch
    SetRebootRequired
    return
} else {
    Write-Host "`tWSL already enabled."
    $packageResult = EnsureWingetPackage "suse.RancherDesktop" "1.10.0"
}

