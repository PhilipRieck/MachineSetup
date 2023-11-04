param(
    [switch] $AspireTooling = $true,
    [switch] $vNextTooling = $true,
    [string] $devDrive = "C:"
)

#iex "& { $(iwr https://raw.githubusercontent.com/PhilipRieck/MachineSetup/main/Go.ps1) }" | Out-Null



#Create folders
$aspireDir = Join-Path $devDrive "dev"
$vNextDir = Join-Path $devDrive "vNext"

if($AspireTooling){
   New-Item -Path $aspireDir -ItemType directory -ErrorAction SilentlyContinue
}
if($vNextTooling){
    New-Item -Path $vNextDir -ItemType directory -ErrorAction SilentlyContinue
}



#Clean up explorer
. "$PSScriptRoot\Parts\Explorer.ps1"
