#Import modules from the local libs
import-module "$PSScriptRoot\..\Modules\Registry.psm1"


#Fix Explorer in win 11 22h2 to what Philip likes

#Show file extensions
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Data 0 -Type DWord > $null

#Show hidden files
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Data 1 -Type DWord > $null

#Show full path in title bar
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Data 1 -Type DWord > $null

#Remove pop-up descriptions
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowInfoTip" -Data 0 -Type DWord > $null

#Disable show preview handlers
set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowPreviewHandlers" -Data 0 -Type DWord > $null

#Launch explorer to This PC
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Data 1 -Type DWord > $null

#Disable sharing wizard
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SharingWizardOn" -Data 0 -Type DWord > $null



#Setup shell settings

#Align taskbar to the left
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Data 0 -Type DWord > $null

#Remove Task View
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Data 0 -Type DWord > $null

#Remove Chat from taskbar
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Data 0 -Type DWord > $null

#Remove widgets from taskbar
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Data 0 -Type DWord > $null

#Remove search bar from taskbar
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskBarMode" -Data 0 -Type DWord > $null

#Set windows darkmode
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Data 0 -Type DWord > $null
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Data 1 -Type DWord > $null

#Hide desktop icons
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Data 1 -Type DWord > $null


#Remove icons from desktop
Remove-Item C:\Users\$env:USERNAME\Desktop\*.lnk -Force
Remove-Item C:\Users\public\Desktop\*.lnk -Force

#Set background to solid color
set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" -Name "BackgroundType" -Data 1 -Type DWord > $null
Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Data "" -Type String > $null
Set-RegistryValue -Path "HKCU:\Control Panel\Colors" -Name "Background" -Data "0 0 0" -Type String > $null


#Reload explorer
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue


