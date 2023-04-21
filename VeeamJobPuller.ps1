# Made by Michael Pugh, SysGroup Plc
# michael.pugh@sysgroup.com

# Get the computer name
$computerName = $env:COMPUTERNAME

# Get the current date and time in the format YYYY-MM-DD_HH-mm-ss
$currentDateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Set the output file path
$outputFilePath = "C:\temp\$computerName-$currentDateTime.csv"

# Get all backup jobs, backup copy jobs, and replication jobs
$jobs = Get-VBRJob | Sort-Object JobSubType

# Initialize an array to store the output data
$outputData = @()

# Loop through each job
foreach ($job in $jobs) {
    # Get all VMs backed up by the job
    $vms = Get-VBRJobObject -Job $job
    
    # Loop through each VM and create an object with the job name, VM name, and empty columns for job type, schedule, and between times
    foreach ($vm in $vms) {
        $vmData = [PSCustomObject]@{
            "Job name" = $job.Name
            "VM name" = $vm.Name
            "Type of Job" = ""
            "Frequency?" = ""
            "Between What times?" = ""
            "Comments" = ""
           
        }
        
        # Add the VM data to the output array
        $outputData += $vmData
    }
}

# Export the output data to a CSV file
$outputData | Export-Csv -Path $outputFilePath -NoTypeInformation

# Display a message indicating where the output file was saved
Write-Host "Output file saved to $outputFilePath"