
function EnsureWingetPackage([string]$packageId, [string]$minimumVersion){

    $package = Get-WingetPackage $packageId
    if($package -eq $null){
        write-host "`tInstalling $packageId via winget"
        winget install -e --id $packageId --source winget
        return 2
    } elseif ($package.CompareToVersion($minimumVersion) -eq "Lesser"){
        write-host "`tUpgrading $packageId via winget"
        winget upgrade --id $packageId --source winget
        return 1
    } else {
        write-host "`t$packageId $($package.InstalledVersion) installed, which satisifes $minimumversion"
        return 0
    }
}

