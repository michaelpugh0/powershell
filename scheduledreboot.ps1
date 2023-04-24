# Prompt user for reboot date and time
$rebootDate = Read-Host -Prompt "Date for reboot (DD/MM/YY)"
$rebootTime = Read-Host -Prompt "Time for reboot (HH:mm)"
$rebootDateTime = [DateTime]::ParseExact("$rebootDate $rebootTime", "dd/MM/yy HH:mm", $null)

# Prompt user for ticket number
$ticketNumber = Read-Host -Prompt "Ticket Number"

# Create new scheduled task
$action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /t 60 /f"
$trigger = New-ScheduledTaskTrigger -Once -At $rebootDateTime
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Reboot" -Description "Reboots the computer at $rebootDateTime for ticket $ticketNumber" -User "SYSTEM" -RunLevel Highest

# Write event to Windows Event Log
$eventMessage = "Reboot scheduled for $rebootDateTime for ticket $ticketNumber."
$eventLog = New-Object System.Diagnostics.EventLog("System")
$eventLog.Source = "PowerShell Scheduled Reboot"
$eventLog.WriteEntry($eventMessage, [System.Diagnostics.EventLogEntryType]::Information)

Write-Host $eventMessage
