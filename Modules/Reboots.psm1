$script:RebootRequired = $false

function SetRebootRequired($value = $true){
    $script:RebootRequired = $value
}
function IsRebootRequired(){
    return $script:RebootRequired
}

function Remove-Reboot()
{
    $currentTasks = Get-ScheduledTask -TaskName "LtiMachineSetup" -ErrorAction Ignore
    foreach($task in $currentTasks){
        Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction Ignore
    }
}

function Invoke-RebootAndContinue([string]$scriptToRun){
    Remove-Reboot

    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $taskName = "LtiMachineSetup"
    $fileName = $scriptToRun
    $taskAction = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-File $fileName"
    $taskTrigger = New-ScheduledTaskTrigger -AtLogOn
    $taskPrincipal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest
    New-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName $taskName -Description "MachineSetup For Lti" -RunLevel Highest -Force -Principal $taskPrincipal
    Restart-Computer -Force
    exit 0
}

