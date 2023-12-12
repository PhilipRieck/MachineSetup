$commonPatName = "lti-ps-pat-" + $env:Computername
$feedcredentialName = "lti-feed-credentials"
$vaultName = 'LtiSecrets'

# see scopes here https://learn.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/oauth?toc=%2Fazure%2Fdevops%2Forganizations%2Fsecurity%2Ftoc.json&view=azure-devops
$commonPatScope = "vso.packaging vso.code_write"

$adoPatUrl = "https://vssps.dev.azure.com/LTiSolutions/_apis/tokens/pats?api-version=7.2-preview.1"
$currentAuthHeader = $null

#Make sure our secret store is setup.
& "$PSScriptRoot\..\Parts\LtiSecrets.ps1"

# We'll need to get the user to auth to Azure AD to get a token for the PAT creation
$module = Get-PsResource MSAL.PS -ErrorAction Ignore
if($module -eq $null){
    Install-PSResource MSAL.PS -TrustRepository
}


function GetSavedPatInfo([string] $patName){
    $secretInfo = Get-SecretInfo -Name $patName -Vault $vaultName
    if($secretInfo -eq $null){
        return @{
            Name = $patName
            AuthorizationId = $null
            ExpiresOn = $null
            Scope = ""
            Token = ""
            }
    }
    return $secretInfo | select-object -ExpandProperty Metadata
}

function SavePatInfo($patInfo){
    Set-Secret -Name $patInfo.Name -Secret $patInfo.Token -Metadata $patInfo -Vault $vaultName
}

function CheckPatInfo($patInfo){
    return ($patInfo -ne $null `
        -and $patInfo.AuthorizationId -ne $null `
        -and $patInfo.Token -ne $null `
        -and $patInfo.ExpiresOn -ne $null `
        -and $patInfo.ExpiresOn -gt (Get-Date))
}

function GetAdAuthHeader(){
    if($currentAuthHeader -ne $null){
        return $currentAuthHeader
    }
    $connctionParams = @{
        ClientId = "129eb9a3-d67a-4959-a66b-08ec3102c31a"
        TenantId = "ddcad772-9ecc-41c2-8fda-eaf9a3f96dae"
        Scopes = @("499b84ac-1321-427f-aa17-267ca6975798/.default")
    }

    # First, try to get one from the windows account broker
    $AdToken = Get-MsalToken @connctionParams -Silent

    if($AdToken -eq $null){
        # If that fails, try to get one interactively
        $AdToken = Get-MsalToken @connctionParams -Interactive
    }

    if($AdToken -eq $null){
        # If that fails, we're done.
        Write-Host "Unable to get AAD token via MSAL.  Exiting."
        exit 1
    }

    $authHeader = @{
        'Authorization' = $AdToken.CreateAuthorizationHeader()
        'Content-Type' = 'application/json'
    }
    $currentAuthHeader = $authHeader
    return $currentAuthHeader
}


function RevokePat([string]$authorizationId){
    $patUrl = $adoPatUrl + "&authorizationId=$authorizationId"
    $patBody = @{
    }
    try{
        $authHeader = GetAdAuthHeader
        $result = Invoke-WebRequest -Uri $patUrl -Method Delete -Headers $authHeader -Body ($patBody | ConvertTo-Json)
    }
    catch{
        Write-Host "Error revoking PAT:  $($_.Exception.Response.StatusCode.value__)"
    }
}

function GetAdoPatByName([string] $patName)
{
    $patBody = @{}
    $continue = $true
    $continuationToken = $null

    while($continue){
        if($continuationToken -ne $null){
            $patUrl = $adoPatUrl + "&continuationToken=$continuationToken"
        } else {
            $patUrl = $adoPatUrl
        }
        try{
            $authHeader = GetAdAuthHeader
            $result = Invoke-WebRequest -Uri $patUrl -Method Get -Headers $authHeader -Body ($patBody | ConvertTo-Json)
            $resultVal = ($result.Content | ConvertFrom-Json)
        } catch {
            Write-Host "Error getting PAT List: $($_.Exception.Response.StatusCode.value__)"
            return $null
        }
        $patPartial = $resultVal.patTokens | Where-Object { $_.displayName -eq $patName }
        if($patPartial -ne $null){
            return $patPartial
        }

        if ([string]::IsNullOrWhitespace($resultVal.continuationToken)){
            $continue = $false
        } else {
            $continuationToken = $resultVal.continuationToken
        }
    }
    return $null
}

function RegeneratePat([string]$patName, [string]$patScope){
    $currentAdo = GetAdoPatByName $patName

    $newPatInfo = CreateAdoPat $patName $patScope
    if($newPatInfo -eq $null){
        return
    }

    SavePatInfo $newPatInfo
    if($currentAdo -ne $null){
        RevokePat $currentAdo.authorizationId
    }
}

function UpdatePatExpiration($patInfo){
    $patUrl = $adoPatUrl
    $validTo = (Get-Date).AddDays(360).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $patBody = @{
        "authorizationId" = $patInfo.AuthorizationId
        "displayName" = $patInfo.Name
        "scope" = $patInfo.Scope
        "allOrgs" = $false
        "validTo" = $validTo
    }

    try{
        $authHeader = GetAdAuthHeader
        $result = Invoke-WebRequest -Uri $patUrl -Method Post -Headers $authHeader -Body ($patBody | ConvertTo-Json)
        $resultVal = ($result.Content | ConvertFrom-Json)
    } catch {
        Write-Host "Error updating PAT expiration:  $($_.Exception.Response.StatusCode.value__)"
        return $patInfo
    }
    $patInfo.ExpiresOn = $resultVal.patToken.validTo
    SavePatInfo $patInfo
    return $patInfo
}

function CreateAdoPat([string]$patName, [string]$patScope){
    $patUrl = $adoPatUrl
    $validTo = (Get-Date).AddDays(360).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $patBody = @{
        "displayName" = $patName
        "scope" = $patScope
        "validTo" = $validTo
        "allOrgs" = $false
    }


    try{
        $authHeader = GetAdAuthHeader
        $result = Invoke-WebRequest -Uri $patUrl -Method Post -Headers $authHeader -Body ($patBody | ConvertTo-Json)
        $resultVal = ($result.Content | ConvertFrom-Json)
        Write-Host "Created PAT $patName (Expires $($resultVal.patToken.validTo))"
    } catch{
        Write-Host "Error creating PAT:  $($_.Exception.Response.StatusCode.value__)"
        return $null
    }

    $patInfo = @{
        Name = $resultVal.patToken.displayName
        Token = $resultVal.patToken.token
        AuthorizationId = $resultVal.patToken.authorizationId
        Scope = $resultVal.patToken.scope
        ExpiresOn = $resultVal.patToken.validTo
    }
    #write-host "`nPAT created $($patInfo.Name)`n$($patInfo | ConvertTo-Json))"
    return $patInfo
}


function EnsureOnePat([string]$patName, [string]$patScope, [Boolean]$force = $false){

    if($force){
        Write-Host "Force specified.  Regenerating PAT $patName."
        RegeneratePat $patName $patScope
        return
    }

    $patInfo = GetSavedPatInfo $patName
    if($patInfo -eq $null){
        Write-Host "Locally saved PAT info is missing. Regenerating PAT"
        RegeneratePat $patName $patScope
        return
    }

    if($patInfo.Token -eq $null){
        Write-Host "Locally saved PAT info is missing token info. Regenerating PAT"
        RegeneratePat $patName $patScope
        return
    }

    if($patInfo.AuthorizationId -eq $null){
        Write-Host "Locally saved PAT info is missing authorizationId. Regenerating PAT"
        RegeneratePat $patName $patScope
        return
    }

    if(($patInfo.ExpiresOn -eq $null) -or ($patInfo.ExpiresOn -lt (Get-Date).AddDays(30))){
        Write-Host "Locally saved PAT info expiration is within 30 days. Updating PAT Expiration"
        UpdatePatExpiration $patInfo
        return
    }

    write-host "ADO PAT $patName is valid.  No action needed."
}

#debugging
function debugPat([string]$patName){
    $patInfo = GetSavedPatInfo $patName
    write-host "Current Pat info for [$patName]:"
    write-host "`tnull:`t`t$($patInfo -eq $null)"
    write-host "`tName:`t`t$($patInfo.Name)"
    write-host "`tToken:`t`t$($patInfo.Token)"
    write-host "`tAuthId:`t`t$($patInfo.AuthorizationId)"
    write-host "`tExpires:`t`t$($patInfo.ExpiresOn)"
    write-host "`tScope:`t`t$($patInfo.Scope)"

    $authHeader = GetAdAuthHeader
    write-host "`nAuthHeader: $($authHeader)"

    $patInfo = GetAdoPatByName $patName
    write-host "`nCurrent Pat info IN ADO for [$patName]:"
    write-host "`tnull:`t`t$($patInfo -eq $null)"
    write-host "`tName:`t`t$($patInfo.Name)"
    write-host "`tToken:`t`t$($patInfo.Token)"
    write-host "`tAuthId:`t`t$($patInfo.AuthorizationId)"
    write-host "`tExpires:`t`t$($patInfo.ExpiresOn)"
    write-host "`tScope:`t`t$($patInfo.Scope)"
}


function AddFeedCredentialsToVault($patInfo){
    write-host "Updating feed credentials in vault $vaultName for $feedcredentialName"
    $secureToken = ($patInfo.Token | ConvertTo-SecureString -AsPlainText -Force)
    $credential = (new-object System.Management.Automation.PSCredential("adouser", $secureToken))
    Set-Secret -Vault $vaultName -Name $feedcredentialName -Secret $credential
}

function RegisterAdoFeedAsPSRepo($force = $false){
    $repo = get-PSResourceRepository vNext -ErrorAction Ignore
    if($repo){
        if(-not $force){
            write-host "vNext repo already registered, no action needed."
            return
        }
        write-host "Unregistering vNext repo."
        Unregister-PSResourceRepository vNext
    }
    write-host "Registering vNext repo with credentials in $vaultName for $feedcredentialName"
    $params = @{
        Name = 'vNext'
        Uri = 'https://pkgs.dev.azure.com/LTiSolutions/d94bf40a-c115-4699-a8d0-be9e02025ef2/_packaging/lti-tools-feed/nuget/v3/index.json'
        Trusted = $true
        CredentialInfo = [Microsoft.PowerShell.PSResourceGet.UtilClasses.PSCredentialInfo]::new($vaultName, $feedcredentialName)
        Force = $true
    }
    Register-PSResourceRepository @params
}

EnsureOnePat $commonPatName $commonPatScope
$patInfo = GetSavedPatInfo $commonPatName
AddFeedCredentialsToVault $patInfo
RegisterAdoFeedAsPSRepo $true
