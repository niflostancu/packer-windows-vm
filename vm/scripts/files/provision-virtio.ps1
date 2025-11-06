# Provisions virtio guest drivers as separate job
# (since packer's winrm communicator gets stuck in the process, it must be run via a fake reboot command)

Start-Transcript -path "C:\Windows\Temp\vm-provision-virtio.log" -Append -force


# fist, install all drivers available
Write-Output 'Installing the virtio drivers...'
$qemuDriversPath = "F:"
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

# Warning: forcefully reboots at the end of the script!
Start-Sleep 10
Stop-Service winrm
Start-Sleep 3
# abort previous shutdown (will issue one later)
shutdown /a

# install the full guest tools.
$guestTools = "$qemuDriversPath\virtio-win-guest-tools.exe"
Write-Host 'Installing the guest tools...'
$guestToolsLog = "$env:TEMP\virtio-guest-tools.log"
& $guestTools /install /norestart /quiet /log $guestToolsLog | Out-String -Stream
# NB 3010 exit code means the computer needs to be restarted.
if ($LASTEXITCODE -and $LASTEXITCODE -ne 3010) {
    throw "failed to install guest tools with exit code $LASTEXITCODE"
}
Write-Host "Asserting that the QEMU-GA (QEMU Guest Agent) service exists"
Get-Service QEMU-GA
Write-Host "Done installing the guest tools."

# assert that the spice agent exists.
Write-Host "Asserting that the spice-agent service exists"
Get-Service spice-agent

# End logging
stop-transcript 

Restart-Computer -Force
