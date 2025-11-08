# Runs sysprep to generalize the machine

Remove-Item -ErrorAction Ignore "C:\Windows\Temp\vm-firstboot.log"

Start-Process -FilePath 'C:/windows/System32/Sysprep/sysprep.exe' `
    -ArgumentList '/oobe /generalize /shutdown "/unattend:$VMSCRIPTS\files\sysprep-unattend.xml"'

exit 0

