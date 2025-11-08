# Install utility apps

Invoke-VMScriptTask -TaskID "provision_winget_apps" -TaskTimeout 600 `
    -ScriptSnippet "Install-BoxstarterPackage -PackageName `"$VMSCRIPTS\snippets.d\box-base-apps.ps1`""

# TODO:
# Invoke-VMScriptTask -TaskID "provision_winget_apps" -TaskTimeout 1800 `
#     -ScriptSnippet "Install-BoxstarterPackage -PackageName `"$VMSCRIPTS\snippets.d\box-developer.ps1`""

