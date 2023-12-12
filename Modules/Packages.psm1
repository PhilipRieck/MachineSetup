
function EnsureWingetPackage([string]$packageId, [semver]$minimumVersion, [scriptblock]$configureCallback){

    $package = Get-WingetPackage $packageId
    if($package -eq $null){
        write-host "Winget: Installing $packageId"
        winget install -e --id $packageId --source winget
        return 2
    } elseif ([semver]$package.InstalledVersion -lt $minimumVersion){
        write-host "Winget: Upgrading $packageId"
        winget upgrade --id $packageId --source winget
        return 1
    } else {
        write-host "Winget: $packageId $($package.InstalledVersion) installed, which satisifes $minimumversion"
        return 0
    }
}

