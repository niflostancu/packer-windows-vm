# Executes either a single script or multiple from the same directory
# A common VM runner environment is setup beforehand.
# When executing from a directory
param(
    [string]$Path,
    [int]$UntilIdx=0,
    [int]$FromIdx=0
)

# Stop the script when a cmdlet or a native command fails
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
$InformationPreference = "Continue"

. "$PSScriptRoot\..\common.ps1"

if ( -Not [System.IO.Path]::IsPathRooted($Path) ) {
    $Path = (Join-Path $VMSCRIPTS $Path) | Resolve-Path
}

if ( ( Test-Path -Path $Path -PathType Leaf ) -and ( $Path -Like "*.ps1" ) ) {
    Write-Information "Running script: $Path"
    . $Path

} elseif ( Test-Path -Path $Path -PathType Container ) {
    Get-ChildItem $path -Filter '*.ps1' | Sort-Object | ForEach-Object {
        if ( -not ( $_.Name -match '^([0-9]+)-' ) ) {
            Write-Warning "$($_.Name) does not match the expected pattern => ignored!"
            return
        }
        $idx = [int]$Matches[1]
        if ( $UntilIdx -gt 0 -And ( $idx -ge $UntilIdx ) ) { return }
        if ( $FromIdx -gt 0 -And ( $idx -lt $Fromidx ) ) { return }
        Write-Information "Running script: $($_.FullName)"
        # reset error preference values
        $ErrorActionPreference = 'Stop'
        $PSNativeCommandUseErrorActionPreference = $true
        . $_.FullName
    }
} else {
    Write-Error "Could not resolve script path: $Path"
}

