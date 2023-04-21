#requires -Version 1

$driveFreeBeforeMB = [math]::Round((Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -Property FreeSpace).FreeSpace / 1048576,2)

Write-Host -Object "Caclulating free space before cleanup"
Start-Sleep -s 3
Write-Host -Object "C: drive has $driveFreeBeforeMB MB free"
Start-Sleep -s 5

Write-Host -Object "Starting by cleaning up Windows Temp folder content"
Start-Sleep -s 3

$tempfolders = @("C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*", "C:\windows\logs\CBS\*")
$null = Remove-Item $tempfolders -force -recurse

Start-Sleep -s 3
Write-Host -Object "Temp folder cleanup complete"
Start-Sleep -s 3
Write-Host -Object 'Removing Windows Service Pack files'

DISM.exe /online /Cleanup-Image /spsuperseded > $null

Start-Sleep -s 3
Write-Host -Object 'Service Pack files removed (where present)'
Start-Sleep -s 3
Write-Host -Object 'Preparing to cleanup Windows Update Installer Manifest Cache'
Start-Sleep -s 3

Write-Host -Object '(Stopping services)'

Stop-Process -ProcessName trustedinstaller -Force -ErrorAction SilentlyContinue
Start-Sleep -s 5
Stop-Service -Name TrustedInstaller -Force -ErrorAction SilentlyContinue
Start-Sleep -s 10

If ((Get-Service -Name TrustedInstaller).Status -eq 'Stopped')
{
    Write-Host -Object 'The Windows Modules Installer Service has been stopped'
    Start-Sleep -s 3
    Write-Host -Object 'Starting cleaning up of Windows Installer Manifest Cache'

    $null = takeown.exe /f "$env:windir\winsxs\ManifestCache\*"
    $null = icacls.exe "$env:windir\winsxs\ManifestCache\*" /GRANT administrators:F
    $null = Remove-Item -Path "$env:windir\winsxs\ManifestCache\*"

    Write-Host -Object 'Windows Installer Manifest Cache cleared'
}
Else
{
    Write-Host -Object 'Windows Modules Installer Service could not be stopped, aborting this section'
}


Write-Host -Object 'Taking steps to prepare WinSxS for cleanup and compression'
    Start-Sleep -s 3
    Write-Host -Object '(Stopping services)'

Stop-Service -Name MsiServer -Force -ErrorAction SilentlyContinue
Start-Sleep -s 10

If ((Get-Service -Name MsiServer).Status -eq 'Stopped')
{
    Write-Host -Object 'The Windows Installer Service has been stopped'
    Start-Sleep -s 3
    Write-Host -Object 'Disabling related services to prevent issues during cleanup'
    Start-Sleep -s 3
    
    Set-Service -Name TrustedInstaller -StartupType Disabled
    Set-Service -Name MsiServer -StartupType Disabled
    
    Write-Host -Object 'OK all prepped. Compressing files..... (this can take a while)'
    
    $null = icacls.exe "$env:windir\WinSxS" /save "$env:windir\WinSxS.acl" /t
    $null = takeown.exe /f "$env:windir\WinSxS" /r
    $null = icacls.exe "$env:windir\WinSxS" /grant administrators:F /t
    $null = compact.exe /s:"$env:windir\WinSxS" /c /a /i * 2>&1 | out-null
    $null = icacls.exe "$env:windir\WinSxS" /setowner 'NT SERVICE\TrustedInstaller' /t
    $null = icacls.exe "$env:windir" /restore "$env:windir\WinSxS.acl"
    Remove-Item -Path "$env:windir\WinSxS.acl" > $null

    Write-Host -Object 'Compression of WinSxS folder complete - Restarting services'

    Set-Service -Name TrustedInstaller -StartupType Automatic
    Set-Service -Name MsiServer -StartupType Manual

    Start-Service TrustedInstaller
    Start-Service MsiServer
   }
Else
{
    Write-Host -Object 'Unable to compress WinSXS as Windows Modules Installer/Windows Installer service still running'
}
Start-Sleep -s 3

Start-Service TrustedInstaller
Start-Service MsiServer

$driveFreeAfterMB = [math]::Round((Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -Property FreeSpace).FreeSpace / 1048576,2)

$driveSpaceDiff = [math]::Round($driveFreeBeforeMB - $driveFreeAfterMB,2)

Write-Host -Object "Cleanup tasks complete"
Start-Sleep -s 5
Write-Host -Object "Total disk space freed = $driveSpaceDiff MB" 
Start-Sleep -s 3
Write-Host -Object "Drive C now has $driveFreeAfterMB MB available"
