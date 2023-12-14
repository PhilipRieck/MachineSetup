
$module = Get-InstalledPsResource Microsoft.PowerShell.SecretManagement -ErrorAction Ignore
if($module -eq $null){
    Install-PSResource Microsoft.PowerShell.SecretManagement -TrustRepository
}
$module = Get-InstalledPsResource Microsoft.PowerShell.SecretStore -ErrorAction Ignore
if($module -eq $null){
    Install-PSResource Microsoft.PowerShell.SecretStore -TrustRepository
    Set-SecretStoreConfiguration -Authentication None -Interaction None
}

$vault = Get-SecretVault -Name LtiSecrets -ErrorAction Ignore
if($vault -eq $null){
    Register-SecretVault -Name LtiSecrets -ModuleName Microsoft.PowerShell.SecretStore
}

#Allow getting secrets from LtiSecrets vault without prompting
$config = Get-SecretStoreConfiguration
if(($config.Interaction -ne "None")){
    # Note that there's actually only one SecretStore vault - it will duplicate the settings to all vaults for that module.
    # See https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/how-to/manage-secretstore?view=ps-modules
    write-Host -ForegroundColor Yellow "Setting LtiSecrets vault to never prompt for secrets. This will affect all 'SecretStore' (local) vaults."
    Set-SecretStoreConfiguration -Interaction None
}


