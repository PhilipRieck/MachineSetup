Import-Module "$PSScriptRoot\Modules\Packages.psm1"


#Git
$result = EnsureWingetPackage "Git.Git" "2.43.0"
if($result -eq 2){
    git config --global credential.helper manager
}

#Windows Terminal
$result = EnsureWingetPackage "Microsoft.WindowsTerminal" "1.18.0"

#VSCode
$result = EnsureWingetPackage "Microsoft.VisualStudioCode" "1.85.0"

