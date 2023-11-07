

#region enums

#endregion enums

[DSCResource()]
class vNextPSRepository
{
    [string] hidden $RepoName = "vNext"
    [string] hidden $RepoUrl =

    [bool] Test()
    {
        $result = Get-PSResourceRepository -Name $RepoName
        return ($result -ne $null) -and ()
    }

    #Never called?
    [bool] Get(){ return $true }

    [void] Set()
    {

    }
}

[DSCResource()]
class vNextModule
{

    [bool] Test()
    {

    }

    #Never called?
    [bool] Get(){ return $true }

    [void] Set()
    {

    }

    hidden Install()
    {
        #Use Install-PSResource
    }

}