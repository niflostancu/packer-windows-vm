# Brings Windows up to date.

if ( $env:VM_NO_UPGRADE -eq '1' ) {
    Write-Output "Upgrade skipped!"
    return
}

# Set DeliveryOptimization to Internet
$regKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" 
New-Item -Path $regKey -Force | out-null
Set-ItemProperty -Path $RegKey -Name DODownloadMode -Type Dword -Value 3 | out-null

# Start the updates
Write-Output 'Updating Windows, this may take some time...'

# $global:DEBUG = $true
Invoke-VMRebootingTask -TaskID "box_winupdate" `
    -ScriptSnippet "Install-BoxstarterPackage -PackageName `"$VMSCRIPTS\snippets.d\box-win-update.ps1`""

