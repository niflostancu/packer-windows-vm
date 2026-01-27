# run the cleanup snippet

Invoke-VMScriptTask -TaskID "cleanup" -Wait -PipeLog -TaskTimeout 600 `
    -ScriptSnippet "& `"$VMSCRIPTS\snippets.d\cleanup.ps1`""

