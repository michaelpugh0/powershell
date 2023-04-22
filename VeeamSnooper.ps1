# Get list of all Veeam backup jobs
$veeamJobs = Get-VBRJob

# Loop through each job and check for last result
foreach ($job in $veeamJobs) {
    $lastResult = Get-VBRJobSession -Job $job | Select-Object -First 1

    # If the last result was a failure, print job name and reason
    if ($lastResult.Result -eq "Failed") {
        Write-Host "Veeam job $($job.Name) failed due to $($lastResult.Reason)"
    }
}

# Get list of all drives and their free space
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Free -ne $null}

# Loop through each drive and print its free space and drive letter
foreach ($drive in $drives) {
    Write-Host "$($drive.Name): $($drive.Free / 1GB) GB free"
}
