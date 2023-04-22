# Define the GitHub repository URL
$githubUrl = "https://api.github.com/repos/michaelpugh0/powershell/contents/"

# Get the list of files in the GitHub repository
$files = Invoke-RestMethod -Uri $githubUrl

# Filter the list to only include PowerShell script files
$scripts = $files | Where-Object { $_.type -eq "file" -and $_.name.EndsWith(".ps1") -and $_.name -ne "run.ps1" -and $_.name -ne "run" }

# Display the list of available scripts to the user
Write-Host "`nAvailable scripts:`n"
for ($i = 0; $i -lt $scripts.Count; $i++) {
    Write-Host ("{0}. {1}" -f ($i + 1), $scripts[$i].name.TrimEnd(".ps1"))
}

# Prompt the user to select a script to run
for ($i = 0; $i -lt 3; $i++) {
    $scriptNumber = Read-Host "`n`nEnter the number of the script to run"
    if ($scriptNumber -ge 1 -and $scriptNumber -le $scripts.Count) {
        break
    }
    else {
        Write-Host "Invalid script number: $scriptNumber" -ForegroundColor Red
        if ($i -eq 2) {
            Write-Host "Maximum attempts exceeded. Exiting..." -ForegroundColor Yellow
            Exit
        }
    }
}

# Find the selected script in the list
$selectedScript = $scripts[$scriptNumber - 1]

# Construct the raw GitHub URL for the script
$rawUrl = $selectedScript.download_url
$outFile = $selectedScript.name.TrimEnd(".ps1")

# Download the script from the raw GitHub URL
Write-Host "`nDownloading script from $rawUrl ..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $rawUrl -OutFile $outFile

# Execute the script
Write-Host "`nExecuting script ..." -ForegroundColor Yellow
Invoke-Expression ".\$outFile"
