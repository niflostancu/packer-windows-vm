# Install utility apps

$ErrorActionPreference = "Stop"

$localUser = [Environment]::Username
Write-Host "Username: $localUser"

Unregister-ScheduledTask -TaskName 'Provision_Winget_Apps' -Confirm:$false -ErrorAction 'silentlycontinue'
Start-Sleep -Seconds 2

Write-Host "Previous task unregistered..."

$boxstarterTask = @{
    Action = (New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoExit -Command "Install-BoxstarterPackage -PackageName C:\Windows\vmfiles\provision-winget-apps.ps1"')
    Trigger = (New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(1))
    TaskName = 'Provision_Winget_Apps'
}
Register-ScheduledTask @boxstarterTask
Write-Host "Boxstarter task running!"

$timeout = 60
$timer =  [Diagnostics.Stopwatch]::StartNew()
while (((Get-ScheduledTask -TaskName 'Provision_Winget_Apps').State -ne 'Ready') `
        -and  ($timer.Elapsed.TotalSeconds -lt $timeout)) {
    Write-Host "Waiting for Boxstarter task to end..."
    Start-Sleep -Seconds 5
}
$timer.Stop()
