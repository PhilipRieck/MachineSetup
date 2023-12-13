
$desiredVersion = [semver]"1.7.3172-preview"
$desiredModuleVersion = [semver]"1.6.3133"

function installWinget(){
    write-host "Installing winget $desiredVersion"
    #Update winget to preview version
    Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v$($desiredVersion)/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
    Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx" -OutFile "$env:TEMP\Microsoft.UI.Xaml.2.7.x64.appx"

    Add-AppxPackage "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx" -ErrorAction SilentlyContinue
    Add-AppxPackage "$env:TEMP\Microsoft.UI.Xaml.2.7.x64.appx" -ErrorAction SilentlyContinue
    Add-AppxPackage "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ErrorAction SilentlyContinue
}


$winget = get-command winget -ErrorAction Ignore
if($winget){
    $wingetVersion = [semver]((winget --version).substring(1))
    if($wingetVersion -ge [semver]$desiredVersion){
        write-host "Winget already installed and up to date."
    } else {
        InstallWinget
    }
} else {
    InstallWinget
}

$module = Get-InstalledPsResource Microsoft.WinGet.Client -ErrorAction Ignore
if(($module -eq $null) -or ([semver]$module.Version -lt $desiredModuleVersion)){
    write-host "Installing winget powershell module"
    Install-PSResource Microsoft.WinGet.Client -TrustRepository
    write-host "Removing old winget powershell modules"
    Uninstall-PSResource Microsoft.WinGet.Client -Version "(, $desiredModuleVersion)"
} else {
    write-host "Winget powershell module up to date."
}