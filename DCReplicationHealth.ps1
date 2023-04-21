# Get the name of the local domain controller
$dcName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().DomainControllers[0].Name

# Check the replication status
$replicationStatus = repadmin /showrepl $dcName

# Check for errors or warnings in the replication status
if ($replicationStatus -match "error|warning") {
    Write-Host "Replication status for $dcName: WARNING"
    Write-Host $replicationStatus
}
else {
    Write-Host "Replication status for $dcName: OK"
}

# Check the health of the replication using dcdiag
$dcdiagOutput = dcdiag /test:replications /v /c

# Check for errors or warnings in the dcdiag output
if ($dcdiagOutput -match "fail|error|warning") {
    Write-Host "Replication health for $dcName: WARNING"
    Write-Host $dcdiagOutput
}
else {
    Write-Host "Replication health for $dcName: OK"
}
