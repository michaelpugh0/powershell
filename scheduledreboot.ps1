param (
    [string]$rebootDate = $(Read-Host "Enter reboot date in DD/MM/YY format"),
    [string]$rebootTime = $(Read-Host "Enter reboot time in HH:mm format"),
    [string]$ticketNumber = $(Read-Host "Enter ticket number")
)

$rebootDateTime = "$rebootDate $rebootTime"
$taskName = "SysGroup One Time Reboot $ticketNumber"
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command Restart-Computer -Force"
$trigger = New-ScheduledTaskTrigger -Once -At $rebootDateTime

try {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings (New-ScheduledTaskSettingsSet) -User "System"
    Write-EventLog -LogName System -Source "Powershell" -EventId 69 -Message "Reboot date: $rebootDate`r`nReboot Time: $rebootTime`r`nTicket Number: $ticketNumber`r`n`r`nExecuted by '$env:USERNAME' at '$([DateTime]::UtcNow.ToString('ddd, dd MMM yyyy HH:mm:ss GMT'))'"
    Write-Host -ForegroundColor Green "Task '$taskName' has been scheduled successfully for $rebootDate at $rebootTime."
} catch {
    Write-EventLog -LogName System -Source "Powershell" -EventId 69 -Message "Error creating task '$taskName': $($_.Exception.Message)`r`n`r`nExecuted by '$env:USERNAME' at '$([DateTime]::UtcNow.ToString('ddd, dd MMM yyyy HH:mm:ss GMT'))'"
    if ($env:USERNAME -ne "Michael.Pugh") {
        Write-Host -ForegroundColor Red "Task creation failed. Please check the event log for more information."
    } else {
        throw
    }
}

Read-Host -Prompt "Press Enter to exit"
