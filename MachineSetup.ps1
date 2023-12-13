Write-Host "Running MachineSetup.ps1. Press any key to continue."
$x = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

#If we're not running as admin in pwsh, warn and exit.
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if(-not $isAdmin){
    write-host -ForegroundColor Yellow "You MUST run this script in an elevated PowerShell session.  Please re-run as administrator."
     $x = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    exit 1
}



Import-Module "$PSScriptRoot\Modules\Reboots.psm1"
Remove-Reboot


#Run the parts in order
$ScriptsToRunInOrder = @(
    "InstallWinget.ps1"
    "AdoFeeds.ps1"
    "CommonTools.ps1"
    "RancherDesktop.ps1"
    "GetPlatformTools.ps1"
)

foreach($script in $ScriptsToRunInOrder){

    #Run the part!
    & "$PSScriptRoot\Parts\$script"

    #Is a Reboot required?
    $reboot = IsRebootRequired
    if($reboot){
        #Reboot
        Write-Host "Rebooting to continue setup.  Please log back in to continue."
        Invoke-RebootAndContinue $PSCommandPath
        exit
    }
}

#Handoff to Lti.Ps.Platformtools from here!
#Install-LtiDevEnvironment

