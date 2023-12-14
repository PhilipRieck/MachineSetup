

$module = Get-InstalledPsResource Microsoft.PowerShell.SecretManagement -ErrorAction Ignore
if($module -eq $null){
    write-host "`tLtiSecrets: Installing SecretManagement."
    Install-PSResource Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore -TrustRepository `
        -Repository PSGallery -Confirm:$false -SkipDependencyCheck -Quiet

    Set-SecretStoreConfiguration -Authentication None -Interaction None -Confirm:$false -Password (ConvertTo-SecureString "LtiSecrets" -AsPlainText -Force)
}

$module = Get-InstalledPsResource Microsoft.PowerShell.SecretStore -ErrorAction Ignore
if($module -eq $null){
    write-host "`tLtiSecrets: Installing Secretstore."
    Install-PSResource Microsoft.PowerShell.SecretStore -TrustRepository -Confirm:$false -SkipDependencyCheck -Quiet
    Set-SecretStoreConfiguration -Authentication None -Interaction None -Confirm:$false -Password (ConvertTo-SecureString "LtiSecrets" -AsPlainText -Force)
}

$vault = Get-SecretVault -Name LtiSecrets -ErrorAction Ignore
if($vault -eq $null){
    write-host "`tLtiSecrets: Creating LtiSecrets vault."
    Register-SecretVault -Name LtiSecrets -ModuleName Microsoft.PowerShell.SecretStore
}
