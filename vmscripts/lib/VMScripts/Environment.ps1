# Utilties for saving / restoring env files

function Save-VMEnvFile {
	param (
    	[Parameter(Mandatory)]
    	[string]$EnvFile
	)
	Get-ChildItem Env: |
    	Select-Object Name, Value |
    	ConvertTo-Json -Depth 2 |
    	Set-Content $EnvFile -Encoding UTF8
}

function Restore-VMEnvFile {
	param (
    	[Parameter(Mandatory)]
    	[string]$EnvFile
	)

	$envVars = Get-Content $EnvFile | ConvertFrom-Json
	foreach ($item in $envVars) {
	    [System.Environment]::SetEnvironmentVariable(
	            $item.Name, $item.Value, 'Process')
	}
}

Export-ModuleMember -Function Save-VMEnvFile
Export-ModuleMember -Function Restore-VMEnvFile
