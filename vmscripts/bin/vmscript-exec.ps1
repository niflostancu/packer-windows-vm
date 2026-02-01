# Executes either a single script or multiple from the same directory
# A common VM runner environment is setup beforehand.
# When executing from a directory
param(
    [string]$Path,
    [int]$UntilIdx=0,
    [int]$FromIdx=0
)

$vmScriptsRoot = (Get-Item $PSScriptRoot).Parent.FullName

# Stop the script when a cmdlet or a native command fails
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
$InformationPreference = "Continue"
. "$vmScriptsRoot\common.ps1"

# Save environment for sched task-based execution
$vmEnvFile = "$vmScriptsRoot\vm-env.json"
Save-VMEnvFile $vmEnvFile

function Run-Script ($ScriptPath) {
    $baseName = (Get-Item $ScriptPath).BaseName
    $normalizedName = ($baseName.ToLowerInvariant() -replace '[^a-z0-9_]+', '_')
    $snippet = @"
`$ErrorActionPreference = 'Stop'
`$PSNativeCommandUseErrorActionPreference = `$true
`$InformationPreference = 'Continue'
. "$vmScriptsRoot\common.ps1"
Restore-VMEnvFile "$vmEnvFile"
. "$ScriptPath"
"@

    $flags = Get-VMScriptFlags $ScriptPath
    if ($flags.RunAsTask) {
        $timeout = if ($flags.TaskTimeout) {$flags.TaskTimeout} else {600}
        Write-Information "Running script: $baseName (as task)"
        $errCode = Invoke-VMScriptTask -TaskID "_vmscript_$normalizedName" -Wait -PipeLog -TaskTimeout $timeout `
            -ScriptSnippet $snippet
        if ($errCode -ne 0) {
            throw "Task failed with exit code $errCode"
        }

    } else {
        Write-Information "Running script: $baseName"
        powershell.exe -NoProfile -Command $snippet
        if ($LASTEXITCODE -ne 0) {
            throw "Script failed with exit code $LASTEXITCODE"
        }
    }
}

if ( -Not [System.IO.Path]::IsPathRooted($Path) ) {
    $Path = (Join-Path $VMSCRIPTS $Path) | Resolve-Path
}

if ( ( Test-Path -Path $Path -PathType Leaf ) -and ( $Path -Like "*.ps1" ) ) {
    Write-Information "Running script: $Path"
    Run-Script $Path

} elseif ( Test-Path -Path $Path -PathType Container ) {
    Get-ChildItem $path -Filter '*.ps1' | Sort-Object | ForEach-Object {
        if ( -not ( $_.Name -match '^([0-9]+)-' ) ) {
            Write-Warning "$($_.Name) does not match the expected pattern => ignored!"
            return
        }
        $idx = [int]$Matches[1]
        if ( $UntilIdx -gt 0 -And ( $idx -ge $UntilIdx ) ) { return }
        if ( $FromIdx -gt 0 -And ( $idx -lt $Fromidx ) ) { return }
        Run-Script $_.FullName
    }
} else {
    Write-Error "Could not resolve script path: $Path"
}

