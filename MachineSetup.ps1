param(
)



#First, do we need to install pwsh version 7.4?
$target = "7.4.0-rc.1"
$pwshFile = "PowerShell-7.4.0-rc.1-win-x64.msi"
$pwshUri = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.0-rc.1/$pwshFile"
$pwshTemp = join-path "$env:TEMP" "$pwshFile"

$needsInstall = $false
if(get-command pwsh -ErrorAction SilentlyContinue){
    $installedVal = pwsh -noprofile -command "((Get-Variable PSVersionTable -ValueOnly).PSVersion -ge [semver]'$($target)')"
    $needsInstall = -not ($installedVal -eq $true)
} else {
    $needsInstall = $true
}

if($needsInstall){
    #Upgrade powershell to 7.4 (rc1 at time of writing)
    Write-Host "Installing PowerShell $target"

    Invoke-WebRequest -Uri $pwshUri -OutFile $pwshTemp
    Start-Process msiexec.exe -Wait -ArgumentList "/i $pwshTemp /quiet /norestart"
}

#Now, run the phases as admin
$psArgs = "-File $PSScriptRoot\RunPhase.ps1"
Start-Process pwsh -Wait -Verb RunAs -ArgumentList $psArgs
