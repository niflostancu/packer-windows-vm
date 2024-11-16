# Tweaking script

# Make sure user does not expire
Get-WmiObject -Class Win32_UserAccount -Filter "name = 'vagrant'" | Set-WmiInstance -Argument @{PasswordExpires = 0}

# Enable NuGet
Install-PackageProvider NuGet -Force

