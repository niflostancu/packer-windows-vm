# run sysprep to generalize the system

if ($env:VM_DO_SYSPREP -eq "1") {
    Write-Output "Running SysPrep..."
    Invoke-VMScriptTask -TaskID "sysprep" -Wait -PipeLog -TaskTimeout 1800 `
        -ScriptSnippet "& `"$VMSCRIPTS\snippets.d\sysprep.ps1`""
}

