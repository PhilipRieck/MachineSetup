
function Set-RegistryValue()
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $Path,
        [String] $Name = $null,
        [String] $Data = "",
        [Microsoft.Win32.RegistryValueKind] $Type = "String",
        [switch] $Elevate
    )

    $existingValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Ignore
    if ($null -eq $existingValue)
    {
        New-Item -Path $Path -Name $Name -Force | Out-Null
        New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Data | Out-Null
    }
    else
    {
        Set-ItemProperty -Path $Path -Name $Name -Value $Data
    }
}