
write-host "Checking for SecretManagement module"
$module = Get-InstalledPsResource Microsoft.PowerShell.SecretManagement -ErrorAction Ignore
if($module -eq $null){
    write-host "Secretmanagement [$module]. Installing."
    Install-PSResource Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore -TrustRepository `
        -Repository PSGallery -Confirm:$false -SkipDependencyCheck -Quiet

    write-host "Setting Secretstore interaction settings."
    Set-SecretStoreConfiguration -Authentication None -Interaction None -Confirm:$false -Password (ConvertTo-SecureString "LtiSecrets" -AsPlainText -Force)
}

write-host "Checking for SecretStore module"
$module = Get-InstalledPsResource Microsoft.PowerShell.SecretStore -ErrorAction Ignore
if($module -eq $null){
    write-host "SecretStore [$module]. Installing."
    Install-PSResource Microsoft.PowerShell.SecretStore -TrustRepository -Confirm:$false -SkipDependencyCheck -Quiet

    write-host "Setting Secretstore interaction settings."
    Set-SecretStoreConfiguration -Authentication None -Interaction None -Confirm:$false -Password (ConvertTo-SecureString "LtiSecrets" -AsPlainText -Force)
}


write-host "Checking for LtiSecrets vault"
$vault = Get-SecretVault -Name LtiSecrets -ErrorAction Ignore
if($vault -eq $null){
    write-host "Vault [$module]. Registering."
    Register-SecretVault -Name LtiSecrets -ModuleName Microsoft.PowerShell.SecretStore
}
