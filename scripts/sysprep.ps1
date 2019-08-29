# Run sysprep to generalize the machine
Remove-Item "C:\Windows\vmfiles\vm-firstboot.log"
start-process -FilePath 'C:/windows/System32/Sysprep/sysprep.exe' -ArgumentList '/oobe /generalize /shutdown "/unattend:C:\Windows\vmfiles\sysprep-unattend.xml"'
exit 0

