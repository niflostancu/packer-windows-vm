# Installs virtualization drivers

$ErrorActionPreference = "Stop"

Write-Output 'Installing the virtio drivers...'
$qemuDriversPath = "F:\"
$vos = "w10"

# first, extract and trust the certificates
$cert = (Get-AuthenticodeSignature "$qemuDriversPath\qxldod\$vos\amd64\qxldod.cat").SignerCertificate
[System.IO.File]::WriteAllBytes("C:\Windows\Temp\redhat_qxldod.cer",
  $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
& certutil.exe -f -addstore "TrustedPublisher" C:\Windows\Temp\redhat_qxldod.cer

$cert = (Get-AuthenticodeSignature "$qemuDriversPath\Balloon\$vos\amd64\blnsvr.exe").SignerCertificate
[System.IO.File]::WriteAllBytes("C:\Windows\Temp\redhat_balloon.cer",
  $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
& certutil.exe -f -addstore "TrustedPublisher" C:\Windows\Temp\redhat_balloon.cer

Get-ChildItem $qemuDriversPath -Include *.inf -Recurse | Where{$_.FullName -like "*w10\amd64\*"} | ForEach-Object {
  Write-Output "Installing the $_ driver..."
  PNPUtil.exe /add-driver $_.FullName /install | out-null
}
# Install qemu-ga
Start-Process msiexec -ArgumentList "/I e:\GUEST-AGENT\qemu-ga-x86_64.msi /qn /norestart" -Wait -NoNewWindow

Write-Output 'Installing the Spice Guest Tools...'
$guestToolsPath = "$qemuDriversPath\virtio-win-guest-tools.exe"
& $guestToolsPath /quiet /log "C:\Windows\vmfiles\virtio-guest-tools.log"

Write-Output 'Done, rebooting...'
exit 0

