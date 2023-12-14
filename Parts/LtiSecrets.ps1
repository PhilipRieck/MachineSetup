
write-host "Checking for SecretManagement module"
$module = Get-InstalledPsResource Microsoft.PowerShell.SecretManagement -ErrorAction Ignore
if($module -eq $null){
    write-host "Secretmanagement [$module]. Installing."
    Install-PSResource Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore -TrustRepository -Repository PSGallery
}

write-host "Checking for SecretStore module"
$module = Get-InstalledPsResource Microsoft.PowerShell.SecretStore -ErrorAction Ignore
if($module -eq $null){
    write-host "SecretStore [$module]. Installing."
    Install-PSResource Microsoft.PowerShell.SecretStore -TrustRepository -Confirm:$false
}

#Allow getting secrets from LtiSecrets vault without prompting
write-host "Checking for Secretstore interaction settings"
$config = Get-SecretStoreConfiguration
if(($config.Interaction -ne "None")){
    write-host "Interaction set to [$config.Interaction] -setting to None.  Auth set to [$config.Authentication] - setting to None."
    # Note that there's actually only one SecretStore vault - it will duplicate the settings to all vaults for that module.
    # See https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/how-to/manage-secretstore?view=ps-modules
    Set-SecretStoreConfiguration -Authentication None -Interaction None -Confirm:$false
}

write-host "Checking for LtiSecrets vault"
$vault = Get-SecretVault -Name LtiSecrets -ErrorAction Ignore
if($vault -eq $null){
    write-host "Vault [$module]. Registering."
    Register-SecretVault -Name LtiSecrets -ModuleName Microsoft.PowerShell.SecretStore
}
