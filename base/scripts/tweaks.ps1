# Tweaking script

# Make sure user does not expire
$localUser = [Environment]::Username
Get-WmiObject -Class Win32_UserAccount -Filter "name = '$localUser'" | Set-WmiInstance -Argument @{PasswordExpires = 0}

# Enable NuGet
Install-PackageProvider NuGet -Force

