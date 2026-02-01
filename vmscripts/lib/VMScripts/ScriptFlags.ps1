# VM script flags utilities

function Get-VMScriptFlags {
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path
    )
    $tokens = $null
    $errors = $null

    [System.Management.Automation.Language.Parser]::ParseFile(
        	(Resolve-Path $Path), [ref]$tokens, [ref]$errors) | Out-Null

    if ($errors) {
        throw "Failed to parse script: $Path"
    }

    $flags = @{}
    foreach ($token in $tokens) {
        switch ($token.Kind) {
            'Comment' {
                if ($token.Text -match '@(?<key>\w+)\s+(?<value>.+)$') {
                    $flags[$matches.key] = $matches.value.Trim()
                }
                continue
            }
            'NewLine' { continue }
            default { break }
        }
    }
    return [pscustomobject]$flags
}

Export-ModuleMember -Function Get-VMScriptFlags

