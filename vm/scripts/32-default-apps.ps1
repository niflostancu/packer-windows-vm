# Install utility apps

$ErrorActionPreference = "Stop"

Import-Module "C:\Windows\vmfiles\lib\VMRunner"

Invoke-VMScriptTask -TaskID "provision_winget_apps" -TaskTimeout 120 `
    -ScriptSnippet 'Install-BoxstarterPackage -PackageName "C:\Windows\vmfiles\provision-winget-apps.ps1"'

