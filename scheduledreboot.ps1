param (
    [string]$RebootDate = $(Read-Host "Enter reboot date in DD/MM/YY format"),
    [string]$RebootTime = $(Read-Host "Enter reboot time in HH:mm format"),
    [string]$TicketNumber = $(Read-Host "Enter ticket number")
)

$RebootDateTime = "$RebootDate $RebootTime"
$TaskName = "SysGroup One Time Reboot $TicketNumber"
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command Restart-Computer -Force"
$Trigger = New-ScheduledTaskTrigger -Once -At $RebootDateTime

try {
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings (New-ScheduledTaskSettingsSet) -User "System"
    Write-EventLog -LogName System -Source "PowerShell" -EventId 69 -Message "Reboot date: $RebootDate`r`nReboot Time: $RebootTime`r`nTicket Number: $TicketNumber`r`n`r`nExecuted by '$env:USERNAME' at '$([DateTime]::UtcNow.ToString('ddd, dd MMM yyyy HH:mm:ss GMT'))'" -ErrorAction Stop
    Write-Host "Task '$TaskName' has been scheduled successfully for $RebootDate at $RebootTime." -ForegroundColor Green
} catch {
    Write-EventLog -LogName System -Source "PowerShell" -EventId 69 -Message "Error creating task '$TaskName': $($_.Exception.Message)`r`n`r`nExecuted by '$env:USERNAME' at '$([DateTime]::UtcNow.ToString('ddd, dd MMM yyyy HH:mm:ss GMT'))'" -ErrorAction Stop
    Write-Host "Task creation failed. Please check the event log for more information." -ForegroundColor Red
}

Read-Host -Prompt "Press Enter to exit"
