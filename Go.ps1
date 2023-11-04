#0. Start powershell as admin
#1. Set-executionpolicy unrestricted
#2. iex "& { $(iwr https://raw.githubusercontent.com/PhilipRieck/MachineSetup/main/Go.ps1) }" | Out-Null

$TempDir = "$env:TEMP\MachineSetup"
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path $TempDir -ItemType Directory > $null
$ZipPath = "$TempDir\main.zip"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://github.com/PhilipRieck/MachineSetup/archive/refs/heads/main.zip -OutFile $ZipPath
$ProgressPreference = 'Continue'
Expand-Archive -LiteralPath $ZipPath -DestinationPath $TempDir
$SetupScript = (Get-ChildItem -Path $TempDir -Filter MachineSetup.ps1 -Recurse).FullName
& $SetupScript @args
Remove-Item $TempDir -Recurse -Force