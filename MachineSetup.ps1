param(
    [switch] $AspireTooling = $true,
    [switch] $vNextTooling = $true,
    [string] $devDrive = "C:",
)


#Import modules from the local libs

#Create folders
$aspireDir = Join-Path $devDrive "dev"
$vNextDir = Join-Path $devDrive "vNext"

if($AspireTooling){
   New-Item -Path $aspireDir -ItemType directory
}
if($vNextTooling){
    New-Item -Path $vNextDir -ItemType directory
}



#Clean up explorer
. "$PSScriptRoot\Parts\Explorer.ps1"
