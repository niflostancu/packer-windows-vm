############################################################################################################
#                                        Remove Scheduled Tasks                                            #
############################################################################################################

#Disables scheduled tasks that are considered unnecessary
write-output "Disabling scheduled tasks"
$disableTasks = @(
    "XblGameSaveTaskLogon"
    "XblGameSaveTask"
    "Consolidator"
    "UsbCeip"
    "DmClient"
    "DmClientOnScenarioDownload"
    "ScheduledDefrag"
)

foreach ($name in $disableTasks) {
    $task = Get-ScheduledTask -TaskName "$name" -ErrorAction SilentlyContinue
    if ($task -ne $null) {
        Disable-ScheduledTask -InputObject $task -ErrorAction SilentlyContinue | out-null
    }
}

Disable-ScheduledTask -TaskName "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" | out-null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Consumer Experiences\CleanUpTemporaryState" | out-null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Consumer Experiences\StartupAppTask" | out-null

############################################################################################################
#                                             Disable Services                                             #
############################################################################################################

# Disable unused services
$services = @(
    "diagnosticshub.standardcollector.service",
    "DiagTrack",               # Diagnostics Tracking Service
    "dmwappushservice",        # WAP Push Message Routing Service
    "HomeGroupListener",       # HomeGroup Listener
    "HomeGroupProvider",       # HomeGroup Provider
    "lfsvc",                   # Geolocation Service
    "MapsBroker",              # Downloaded Maps Manager
    "NetTcpPortSharing",       # Net.Tcp Port Sharing Service
    "RemoteRegistry",          # Remote Registry
    "SharedAccess",            # Internet Connection Sharing (ICS)
    "TrkWks",                  # Distributed Link Tracking Client
    "WbioSrvc",                # Windows Biometric Service
    "WlanSvc",                 # WLAN AutoConfig
    "WMPNetworkSvc",           # Windows Media Player Network Sharing Service
    "WSearch",                 # Windows Search
    "XblAuthManager",          # Xbox Live Auth Manager
    "XblGameSave",             # Xbox Live Game Save Service
    "XboxNetApiSvc",           # Xbox Live Networking Service
    "WerSvc",
    "PcaSvc",
    "FileSyncHelper",
    "PhoneSvc",
    "QWAVE",
    "SSDPSRV",
    "DusmSvc",
    "HvHost",
    "nvagent"
)

Write-Output "Disabling services..."
foreach ($service in $services) {
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "Disabled service: $service" -ForegroundColor Gray
}
