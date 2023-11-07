#First, ensure we're running as admin.  Fail if not.


#Install newer winget
Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.7.2782-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx" -OutFile "$env:TEMP\Microsoft.UI.Xaml.2.7.x64.appx"

Add-AppxPackage "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
Add-AppxPackage "$env:TEMP\Microsoft.UI.Xaml.2.7.x64.appx"
Add-AppxPackage "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

#Install winget powershell packages
Install-PSResource -Name Microsoft.WinGet.Client -TrustRepository

#Clean up explorer
. "$PSScriptRoot\Parts\Explorer.ps1"

#Create folders
$aspireDir = Join-Path $devDrive "dev"
$vNextDir = Join-Path $devDrive "vNext"

if($AspireTooling){
   New-Item -Path $aspireDir -ItemType directory -ErrorAction SilentlyContinue
   Add-MpPreference -ExclusionPath $aspireDir
}
if($vNextTooling){
    New-Item -Path $vNextDir -ItemType directory -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $vNextDir
}

#install windows terminal if not installed
winget install -e --id Microsoft.WindowsTerminal --source winget

#install vscode
winget install -e --id Microsoft.VisualStudioCode --source winget


#install and configure Git
winget install -e --id Git.Git --source winget
git config --global credential.helper manager


#Install WSL
wsl --install --no-Launch



#At this point, before installing Rancher, we need to reboot.

