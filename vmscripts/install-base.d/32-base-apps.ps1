# Install basic apps

Invoke-VMScriptTask -TaskID "provision_winget_apps" -TaskTimeout 600 `
    -ScriptSnippet "Install-BoxstarterPackage -DisableReboots -PackageName `"$VMSCRIPTS\snippets.d\box-base-apps.ps1`""

