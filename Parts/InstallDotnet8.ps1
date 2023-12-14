Import-Module "$PSScriptRoot\..\Modules\Packages.psm1"

$result = EnsureWingetPackage "Microsoft.DotNet.SDK.8" "8.0.100"