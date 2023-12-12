

$module = Find-PSResource -Name Lti.Ps.PlatformTools -Repository vNext -ErrorAction Ignore

if($module -eq $null){
    Write-Host "Unable to find latest version of Lti.Ps.PlatformTools in vNext repository. Unable to continue."
    exit 1
}

$latestVersion = [semver]$module.Version
try{
    $currentVersion = [semver](Get-InstalledPsResource Lti.Ps.PlatformTools)[0].Version
}
catch{
    $currentVersion = $null
}


if(($currentVersion -eq $null -or ($latestVersion -gt $currentVersion)){
    Write-Host "Installing Lti.Ps.PlatformTools $latestVersion"
    Install-PSResource Lti.Ps.PlatformTools -Repository vNext -Force

    if($currentVersion -ne $null){
        Write-Host "Removing old versions of Lti.Ps.PlatformTools"
        Uninstall-PSResource Lti.Ps.PlatformTools -Version "(,$latestVersion)" -Force
    }
}
