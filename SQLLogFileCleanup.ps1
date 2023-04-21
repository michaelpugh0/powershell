# Deletes any SQL Log file in D:/ older than 30 days

# Set the path to the SQL log folder
$logFolder = "D:\MSSQL\Log"

# Get the current date and subtract 30 days
$cutOffDate = (Get-Date).AddDays(-30)

# Get all SQL log files that are older than 30 days
$oldLogFiles = Get-ChildItem $logFolder -Filter "*.log" -Recurse | Where-Object { $_.LastWriteTime -lt $cutOffDate }

# Delete each old log file
foreach ($oldLogFile in $oldLogFiles) {
    Remove-Item $oldLogFile.FullName -Force
}

# Output the number of files deleted
$numFilesDeleted = $oldLogFiles.Count
Write-Host "$numFilesDeleted old SQL log files have been deleted."
