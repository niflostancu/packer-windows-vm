############################################################################################################
#                                        Remove Registry Keys                                              #
############################################################################################################

# First, create the non-default registry drives
New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR
New-PSDrive -PSProvider Registry -Root HKEY_CURRENT_CONFIG -Name HKCC
New-PSDrive -PSProvider Registry -Root HKEY_USERS -Name HKU

# We need to grab all SIDs to remove at user level
$UserSIDs = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Select-Object -ExpandProperty PSChildName

$Keys = @(
    # Remove Background Tasks
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

    # Windows File
    "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"

    # Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

    # Scheduled Tasks to delete
    "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"

    # Windows Protocol Keys
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

    # Windows Share Target
    "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
)
ForEach ($Key in $Keys) {
    write-output "Removing $Key from registry"
    If (Test-Path $Key) {
        Remove-Item $Key -Recurse
    }
}

#Disables Windows Feedback Experience
write-output "Disabling Windows Feedback Experience program"
$Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
If (!(Test-Path $Advertising)) {
    New-Item $Advertising | out-null
}
If (Test-Path $Advertising) {
    Set-ItemProperty $Advertising Enabled -Value 0 | out-null
}

#Stops Cortana from being used as part of your Windows Search Function
write-output "Stopping Cortana from being used as part of your Windows Search Function"
$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
If (!(Test-Path $Search)) {
    New-Item $Search | out-null
}
If (Test-Path $Search) {
    Set-ItemProperty $Search AllowCortana -Value 0 | out-null
}

#Disables Web Search in Start Menu
write-output "Disabling Bing Search in Start Menu"
$WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
If (!(Test-Path $WebSearch)) {
    New-Item $WebSearch | out-null
}
Set-ItemProperty $WebSearch DisableWebSearch -Value 1 | out-null
##Loop through all user SIDs in the registry and disable Bing Search
foreach ($sid in $UserSIDs) {
    $WebSearch = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    If (!(Test-Path $WebSearch)) {
        New-Item $WebSearch | out-null
    }
    Set-ItemProperty $WebSearch BingSearchEnabled -Value 0 | out-null
}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0 | out-null

#Stops the Windows Feedback Experience from sending anonymous data
write-output "Stopping the Windows Feedback Experience program"
$Period = "HKCU:\Software\Microsoft\Siuf\Rules"
If (!(Test-Path $Period)) {
    New-Item $Period | out-null
}
Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 | out-null

##Loop and do the same
foreach ($sid in $UserSIDs) {
    $Period = "Registry::HKU\$sid\Software\Microsoft\Siuf\Rules"
    If (!(Test-Path $Period)) {
        New-Item $Period | out-null
    }
    Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 | out-null
}

##Disables games from showing in Search bar
write-output "Adding Registry key to stop games from search bar"
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
If (!(Test-Path $registryPath)) {
    New-Item $registryPath | out-null
}
Set-ItemProperty $registryPath EnableDynamicContentInWSB -Value 0 | out-null

#Prevents bloatware applications from returning and removes Start Menu suggestions
write-output "Adding Registry key to prevent bloatware apps from returning"
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
If (!(Test-Path $registryPath)) {
    New-Item $registryPath | out-null
}
Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 | out-null

If (!(Test-Path $registryOEM)) {
    New-Item $registryOEM | out-null
}
Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 | out-null
Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 | out-null
Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 | out-null
Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 | out-null
Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 | out-null
Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0 | out-null

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $registryOEM = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (!(Test-Path $registryOEM)) {
        New-Item $registryOEM | out-null
    }
    Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 | out-null
    Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 | out-null
    Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 | out-null
    Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 | out-null
    Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 | out-null
    Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0 | out-null
}

#Preping mixed Reality Portal for removal
write-output "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
$Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"
If (Test-Path $Holo) {
    Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 | out-null
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $Holo = "Registry::HKU\$sid\Software\Microsoft\Windows\CurrentVersion\Holographic"
    If (Test-Path $Holo) {
        Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 | out-null
    }
}

#Disables Wi-fi Sense
write-output "Disabling Wi-Fi Sense"
$WifiSense1 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
$WifiSense2 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
$WifiSense3 = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
If (!(Test-Path $WifiSense1)) {
    New-Item $WifiSense1 | out-null
}
Set-ItemProperty $WifiSense1  Value -Value 0
If (!(Test-Path $WifiSense2)) {
    New-Item $WifiSense2 | out-null
}
Set-ItemProperty $WifiSense2  Value -Value 0 | out-null
Set-ItemProperty $WifiSense3  AutoConnectAllowedOEM -Value 0 | out-null

#Disables live tiles
write-output "Disabling live tiles"
$Live = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
If (!(Test-Path $Live)) {
    New-Item $Live | out-null
}
Set-ItemProperty $Live  NoTileApplicationNotification -Value 1 | out-null

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $Live = "Registry::HKU\$sid\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
    If (!(Test-Path $Live)) {
        New-Item $Live | out-null
    }
    Set-ItemProperty $Live  NoTileApplicationNotification -Value 1 | out-null
}

#Turns off Data Collection via the AllowTelemtry key by changing it to 0
# This is needed for Intune reporting to work, uncomment if using via other method
write-output "Turning off Data Collection"
$DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
$DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
If (Test-Path $DataCollection1) {
    Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0 | out-null
}
If (Test-Path $DataCollection2) {
    Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0 | out-null
}
If (Test-Path $DataCollection3) {
    Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0 | out-null
}

# Disable Location Tracking
write-output "Disabling Location Tracking"
$SensorState = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
$LocationConfig = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
If (!(Test-Path $SensorState)) {
    New-Item $SensorState | out-null
}
Set-ItemProperty $SensorState SensorPermissionState -Value 0
If (!(Test-Path $LocationConfig)) {
    New-Item $LocationConfig | out-null
}
Set-ItemProperty $LocationConfig Status -Value 0 | out-null

# Disables People icon on Taskbar
write-output "Disabling People icon on Taskbar"
$People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
If (Test-Path $People) {
    Set-ItemProperty $People -Name PeopleBand -Value 0 | out-null
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $People = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
    If (Test-Path $People) {
        Set-ItemProperty $People -Name PeopleBand -Value 0 | out-null
    }
}

write-output "Disabling Cortana"
$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
If (!(Test-Path $Cortana1)) {
    New-Item $Cortana1 | out-null
}
Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0
If (!(Test-Path $Cortana2)) {
    New-Item $Cortana2 | out-null
}
Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 | out-null
Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 | out-null
If (!(Test-Path $Cortana3)) {
    New-Item $Cortana3 | out-null
}
Set-ItemProperty $Cortana3 HarvestContacts -Value 0 | out-null

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $Cortana1 = "Registry::HKU\$sid\SOFTWARE\Microsoft\Personalization\Settings"
    $Cortana2 = "Registry::HKU\$sid\SOFTWARE\Microsoft\InputPersonalization"
    $Cortana3 = "Registry::HKU\$sid\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    If (!(Test-Path $Cortana1)) {
        New-Item $Cortana1 | out-null
    }
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 | out-null
    If (!(Test-Path $Cortana2)) {
        New-Item $Cortana2 | out-null
    }
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 | out-null
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 | out-null
    If (!(Test-Path $Cortana3)) {
        New-Item $Cortana3 | out-null
    }
    Set-ItemProperty $Cortana3 HarvestContacts -Value 0 | out-null
}

# Removes 3D Objects from the 'My Computer' submenu in explorer
write-output "Removing 3D Objects from explorer 'My Computer' submenu"
$Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
$Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
If (Test-Path $Objects32) {
    Remove-Item $Objects32 -Recurse | out-null
}
If (Test-Path $Objects64) {
    Remove-Item $Objects64 -Recurse | out-null
}

# Removes the Microsoft Feeds from displaying
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
$Name = "EnableFeeds"
$value = "0"
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | out-null
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | out-null
}

else {
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | out-null
}

# Kill Cortana again
Get-AppxPackage Microsoft.549981C3F5F10 -allusers | Remove-AppxPackage

############################################################################################################
#                                   Disable unwanted OOBE screens for Device Prep                          #
############################################################################################################

$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"
$registryPath2 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
$Name1 = "DisablePrivacyExperience"
$Name2 = "DisableVoice"
$Name3 = "PrivacyConsentStatus"
$Name4 = "Protectyourpc"
$Name5 = "HideEULAPage"
$Name6 = "EnableFirstLogonAnimation"
New-ItemProperty -Path $registryPath -Name $name1 -Value 1 -PropertyType DWord -Force | out-null
New-ItemProperty -Path $registryPath -Name $name2 -Value 1 -PropertyType DWord -Force | out-null
New-ItemProperty -Path $registryPath -Name $name3 -Value 1 -PropertyType DWord -Force | out-null
New-ItemProperty -Path $registryPath -Name $name4 -Value 3 -PropertyType DWord -Force | out-null
New-ItemProperty -Path $registryPath -Name $name5 -Value 1 -PropertyType DWord -Force | out-null
New-ItemProperty -Path $registryPath2 -Name $name6 -Value 0 -PropertyType DWord -Force | out-null


############################################################################################################
#                                                   Disable Spotlight                                      #
############################################################################################################

write-output "Disabling Windows Spotlight on lockscreen"
$spotlight = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
If (Test-Path $spotlight) {
    Set-ItemProperty $spotlight -Name "RotatingLockScreenOverlayEnabled" -Value 0 | out-null
    Set-ItemProperty $spotlight -Name "RotatingLockScreenEnabled" -Value 0 | out-null
}
# Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $spotlight = "Registry::HKU\$sid\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (Test-Path $spotlight) {
        Set-ItemProperty $spotlight -Name "RotatingLockScreenOverlayEnabled" -Value 0 | out-null
        Set-ItemProperty $spotlight -Name "RotatingLockScreenEnabled" -Value 0 | out-null
    }
}

write-output "Disabling Windows Spotlight on background"
$spotlight = 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent'
If (Test-Path $spotlight) {
    Set-ItemProperty $spotlight -Name "DisableSpotlightCollectionOnDesktop" -Value 1 | out-null
    Set-ItemProperty $spotlight -Name "DisableWindowsSpotlightFeatures" -Value 1 | out-null
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $spotlight = "Registry::HKU\$sid\Software\Policies\Microsoft\Windows\CloudContent"
    If (Test-Path $spotlight) {
        Set-ItemProperty $spotlight -Name "DisableSpotlightCollectionOnDesktop" -Value 1 | out-null
        Set-ItemProperty $spotlight -Name "DisableWindowsSpotlightFeatures" -Value 1 | out-null
    }
}

############################################################################################################
#                                       Fix for Gaming Popups                                              #
############################################################################################################

write-output "Adding GameDVR Fix"
$gamedvr = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'
If (Test-Path $gamedvr) {
    Set-ItemProperty $gamedvr -Name "AppCaptureEnabled" -Value 0 | out-null
    Set-ItemProperty $gamedvr -Name "NoWinKeys" -Value 1 | out-null
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $gamedvr = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
    If (Test-Path $gamedvr) {
        Set-ItemProperty $gamedvr -Name "AppCaptureEnabled" -Value 0 | out-null
        Set-ItemProperty $gamedvr -Name "NoWinKeys" -Value 1 | out-null
    }
}

$gameconfig = 'HKCU:\System\GameConfigStore'
If (Test-Path $gameconfig) {
    Set-ItemProperty $gameconfig -Name "GameDVR_Enabled" -Value 0 | out-null
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $gameconfig = "Registry::HKU\$sid\System\GameConfigStore"
    If (Test-Path $gameconfig) {
        Set-ItemProperty $gameconfig -Name "GameDVR_Enabled" -Value 0 | out-null
    }
}
