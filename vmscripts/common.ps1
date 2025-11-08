# include with `. "$PSScriptRoot/../common.ps1"`

# export some global variables from the environment
$global:VMSCRIPTS = $env:VMSCRIPTS
if ( -not $env:VMSCRIPTS ) { $global:VMSCRIPTS = "C:\Windows\vmscripts" }

# import VM runner modules
Import-Module "$VMSCRIPTS\lib\VMRunner"

