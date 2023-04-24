#Created by Michael Pugh, SysGroup PLC. All Rights Reserved.
#For any bugs or issues, please contact Michael.Pugh@SysGroup.com

# Prompt user for reboot date and time
$rebootDate = Read-Host -Prompt "Date for reboot (DD/MM/YY)"
$rebootTime = Read-Host -Prompt "Time for reboot (HH:mm)"
$rebootDateTime = [DateTime]::ParseExact("$rebootDate $rebootTime", "dd/MM/yy HH:mm", $null)

## Prompt user for reboot date and time
$rebootDate = Read-Host -Prompt "Date for reboot (DD/MM/YY)"
$rebootTime = Read-Host -Prompt "Time for reboot (HH:mm)"
$rebootDateTime = [DateTime]::ParseExact("$rebootDate $rebootTime", "dd/MM/yy HH:mm", $null)

# Prompt user for ticket number
$ticketNumber = Read-Host -Prompt "Ticket Number"

try {
    # Create new scheduled task
    $taskName = "SysGroup One time reboot $ticketNumber"
    $action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /t 60 /f"
    $trigger = New-ScheduledTaskTrigger -Once -At $rebootDateTime
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Reboots the computer at $rebootDateTime for ticket $ticketNumber" -User "SYSTEM" -RunLevel Highest

    # Write event to Windows Event Log
    $eventMessage = "Reboot scheduled for $rebootDateTime for ticket $ticketNumber."
    $eventLog = New-Object System.Diagnostics.EventLog("System")
    $eventLog.Source = "PowerShell Scheduled Reboot"
    $eventLog.WriteEntry($eventMessage, [System.Diagnostics.EventLogEntryType]::Warning, 69)

    Write-Host $eventMessage
}
catch {
    Write-Warning "An error occurred while scheduling the reboot. Please contact Michael.Pugh@SysGroup.com."
    Write-Error $_.Exception.Message
}

