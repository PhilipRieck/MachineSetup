function Get-MachineSetupPhase()
{
    [CmdletBinding()]
    param(
    )

    $Phase = 0
    $currentTask = Get-ScheduledTask -TaskName "MachineSetupPhase*" -ErrorAction Ignore
    if($null -eq $currentTask){
        $Phase = 0
    }
    else{
        $taskName = $currentTask.TaskName
        $Phase = $taskName.Substring($taskName.Length - 1)
    }
    return $Phase
}

function Remove-MachineSetupPhase()
{
    [CmdletBinding()]
    param()

    $currentTasks = Get-ScheduledTask -TaskName "MachineSetupPhase*" -ErrorAction Ignore
    foreach($task in $currentTasks){
        Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction Ignore
    }
}

function Set-MachineSetupPhase()
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int] $Phase
    )

    Remove-MachineSetupPhase

    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $taskName = "MachineSetup\Phase$($Phase)"
    $fileName = Join-Path $PSScriptRoot "..\RunPhase.ps1"
    $taskAction = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-File $fileName"
    $taskTrigger = New-ScheduledTaskTrigger -AtLogOn
    $taskPrincipal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest
    New-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName $taskName -Description "MachineSetup Phase $Phase" -RunLevel Highest -Force -Principal $taskPrincipal
}

