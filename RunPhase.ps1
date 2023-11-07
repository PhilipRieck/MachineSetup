
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if($isAdmin -eq $false){
    Write-Host "This script must be run as administrator.  Please re-run as administrator."
    exit
}

import-module "$PSScriptRoot\Modules\Phases.psm1"


$Phase = Get-MachineSetupPhase



$phaseFile = Join-Path $PSScriptRoot "Phase$($Phase).ps1"
if(Test-Path $phaseFile){
    Write-Host "Running Phase $Phase"
    . $phaseFile
}
else{
    Write-Host "Phase $Phase not found.  Removing job and exiting."
    Remove-MachineSetupPhase
    exit
}
