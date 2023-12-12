#NOTE: Do not use [semver] in here, since we might be on older powershell versions!
$target = "7.4.0"

if($PSVersionTable.PSVersion.ToString() -match "^7.4"){
    Write-Host "PWSH installed and up to date, and we're running in it. Going right to MachineSetup."
    & "$PSScriptRoot\MachineSetup.ps1"
    return
}


$pwshFile = "PowerShell-$target-win-x64.msi"
$pwshUri = "https://github.com/PowerShell/PowerShell/releases/download/v$target/$pwshFile"
$pwshTemp = join-path "$env:TEMP" "$pwshFile"

$needsInstall = $false
$cmd = get-command pwsh -ErrorAction SilentlyContinue

$needsInstall = $false
if(get-command pwsh -ErrorAction SilentlyContinue){
    $installedVal = pwsh -noprofile -command "((Get-Variable PSVersionTable -ValueOnly).PSVersion -ge [semver]'$($target)')"
    $needsInstall = -not ($installedVal -eq $true)
    Write-Host "PWSH installed, version ok: $installedVal"
} else {
    Write-Host "Cannot find pwsh command."
    $needsInstall = $true
}

if($needsInstall){
    #Upgrade powershell to 7.4 (rc1 at time of writing)
    Write-Host "Installing PowerShell $target"

    Invoke-WebRequest -Uri $pwshUri -OutFile $pwshTemp

    $msiParams = "/i", "`"$pwshTemp`"", "/quiet", "/norestart", "REGISTER_MANIFEST=1", "USE_MU=1", "ENABLE_MU=1", "ADD_PATH=1"

    $p = Start-Process msiexec.exe -Wait -ArgumentList $msiParams -NoNewWindow -PassThru
    Write-Host "PWSH install Completed with $($p.ExitCode)"
} else {
    Write-Host "PWSH already installed and up to date."
}


$psArgs = "-File $PSCommandPath"
Start-Process pwsh -ArgumentList $PsArgs -Wait -Verb RunAs
