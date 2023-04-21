# Deletes any SQL Log file on target drive letter older than 30 days
# Prompt the user to enter the drive letter where SQL log files are stored
$driveLetter = Read-Host "Enter the drive letter where SQL log files are stored (e.g. D:)"

# Set the path to the SQL log folder
$logFolder = "$driveLetter\MSSQL\Log"

# Get the current date and subtract 30 days
$cutOffDate = (Get-Date).AddDays(-30)

# Get all SQL log files that are older than 30 days
$oldLogFiles = Get-ChildItem $logFolder -Filter "*.log" -Recurse | Where-Object { $_.LastWriteTime -lt $cutOffDate }

# Check if any old log files were found
if ($oldLogFiles.Count -eq 0) {
    Write-Host "No SQL log files older than 30 days were found."
    Exit
}

# Explain what the script will do and ask for confirmation before proceeding
$numFilesToDelete = $oldLogFiles.Count
$sizeToDelete = ($oldLogFiles | Measure-Object -Property Length -Sum).Sum / 1MB
$confirmationMessage = "This will delete $numFilesToDelete SQL log files totaling $sizeToDelete MB that are older than 30 days from $logFolder. Do you want to proceed? (Y/N)"
$userConfirmation = Read-Host $confirmationMessage

if ($userConfirmation.ToLower() -ne "y") {
    Write-Host "Cleanup aborted by user."
    Exit
}

# Delete each old log file
foreach ($oldLogFile in $oldLogFiles) {
    Remove-Item $oldLogFile.FullName -Force
}

# Output the number of files deleted
Write-Host "$numFilesToDelete old SQL log files totaling $sizeToDelete MB have been deleted from $logFolder."
