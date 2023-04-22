# Define the GitHub repository URL
$githubUrl = "https://api.github.com/repos/michaelpugh0/powershell/contents/"

# Get the list of files in the GitHub repository
$files = Invoke-RestMethod -Uri $githubUrl

# Filter the list to only include PowerShell script files
$scripts = $files | Where-Object { $_.type -eq "file" -and $_.name.EndsWith(".ps1") }

# Display the list of available scripts to the user
Write-Host "`nAvailable scripts:`n"
for ($i = 0; $i -lt $scripts.Count; $i++) {
    Write-Host ("{0}. {1}" -f ($i + 1), $scripts[$i].name.Replace(".ps1", ""))
}

# Prompt the user to select a script to run
$scriptNumber = Read-Host "`n`nEnter the number of the script to run"

# Check if the easter egg number was entered
if ($scriptNumber -eq "007") {
    Write-Host @"
  /\_/\  
 ( o   o )
=( I )= Meow! - My name is Alfie
  -(_)-
  ______
 /|_||_\`.__
(   _    _ _\
=`-(_)--(_)-'  OH NO! A CAT!
"@
}
else {
    # Find the selected script in the list
    $selectedScript = $scripts[$scriptNumber - 1]

    if ($selectedScript) {
        # Construct the raw GitHub URL for the script
        $rawUrl = $selectedScript.download_url
        $outFile = $selectedScript.name.Split("/")[-1].Replace(".ps1", "")

        # Download the script from the raw GitHub URL
        Write-Host "`nDownloading script from $rawUrl ..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $rawUrl -OutFile "$outFile.ps1"

        # Execute the script
        Write-Host "`nExecuting script ..." -ForegroundColor Yellow
        Invoke-Expression ".\$outFile.ps1"
    }
    else {
        Write-Host "Invalid script number: $scriptNumber" -ForegroundColor Red
    }
}
