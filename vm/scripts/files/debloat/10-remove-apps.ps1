############################################################################################################
#                                        Remove AppX Packages                                              #
############################################################################################################

$WhitelistedApps = @(
    'Microsoft.WindowsNotepad',
    'Microsoft.CompanyPortal',
    'Microsoft.ScreenSketch',
    'Microsoft.WindowsCalculator',
    'Microsoft.WindowsStore',
    'Microsoft.Windows.Photos',
    'Microsoft.MSPaint',
    '.NET Framework',
    'Microsoft.HEIFImageExtension',
    'Microsoft.StorePurchaseApp',
    'Microsoft.VP9VideoExtensions',
    'Microsoft.WebMediaExtensions',
    'Microsoft.WebpImageExtension',
    'Microsoft.DesktopAppInstaller',
    'Microsoft.SecHealthUI',
    'Microsoft.Paint',
    'Microsoft.WindowsTerminal',
    'Microsoft.MicrosoftEdge.Stable'
    'Microsoft.MPEG2VideoExtension',
    'Microsoft.HEVCVideoExtension',
    'Microsoft.AV1VideoExtension'
)

#NonRemovable Apps that where getting attempted and the system would reject the uninstall, speeds up debloat and prevents 'initalizing' overlay when removing apps
$NonRemovable = @(
    '1527c705-839a-4832-9118-54d4Bd6a0c89',
    'c5e2524a-ea46-4f67-841f-6a9465d9d515',
    'E2A4F912-2574-4A75-9BB0-0D023378592B',
    'F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE',
    'InputApp',
    'Microsoft.AAD.BrokerPlugin',
    'Microsoft.AccountsControl',
    'Microsoft.BioEnrollment',
    'Microsoft.CredDialogHost',
    'Microsoft.ECApp',
    'Microsoft.LockApp',
    'Microsoft.MicrosoftEdgeDevToolsClient',
    'Microsoft.MicrosoftEdge',
    'Microsoft.PPIProjection',
    'Microsoft.Win32WebViewHost',
    'Microsoft.Windows.Apprep.ChxApp',
    'Microsoft.Windows.AssignedAccessLockApp',
    'Microsoft.Windows.CapturePicker',
    'Microsoft.Windows.CloudExperienceHost',
    'Microsoft.Windows.ContentDeliveryManager',
    'Microsoft.Windows.Cortana',
    'Microsoft.Windows.NarratorQuickStart',
    'Microsoft.Windows.ParentalControls',
    'Microsoft.Windows.PeopleExperienceHost',
    'Microsoft.Windows.PinningConfirmationDialog',
    'Microsoft.Windows.SecHealthUI',
    'Microsoft.Windows.SecureAssessmentBrowser',
    'Microsoft.Windows.ShellExperienceHost',
    'Microsoft.Windows.XGpuEjectDialog',
    'Microsoft.XboxGameCallableUI',
    'Windows.CBSPreview',
    'windows.immersivecontrolpanel',
    'Windows.PrintDialog',
    'Microsoft.VCLibs.140.00',
    'Microsoft.Services.Store.Engagement',
    'Microsoft.UI.Xaml.2.0',
    'Microsoft.AsyncTextService',
    'Microsoft.UI.Xaml.CBS',
    'Microsoft.Windows.CallingShellApp',
    'Microsoft.Windows.OOBENetworkConnectionFlow',
    'Microsoft.Windows.PrintQueueActionCenter',
    'Microsoft.Windows.StartMenuExperienceHost',
    'MicrosoftWindows.Client.CBS',
    'MicrosoftWindows.Client.Core',
    'MicrosoftWindows.UndockedDevKit',
    'NcsiUwpApp',
    'Microsoft.NET.Native.Runtime.2.2',
    'Microsoft.NET.Native.Framework.2.2',
    'Microsoft.UI.Xaml.2.8',
    'Microsoft.UI.Xaml.2.7',
    'Microsoft.UI.Xaml.2.3',
    'Microsoft.UI.Xaml.2.4',
    'Microsoft.UI.Xaml.2.1',
    'Microsoft.UI.Xaml.2.2',
    'Microsoft.UI.Xaml.2.5',
    'Microsoft.UI.Xaml.2.6',
    'Microsoft.VCLibs.140.00.UWPDesktop',
    'MicrosoftWindows.Client.LKG',
    'MicrosoftWindows.Client.FileExp',
    'Microsoft.WindowsAppRuntime.1.5',
    'Microsoft.WindowsAppRuntime.1.3',
    'Microsoft.WindowsAppRuntime.1.1',
    'Microsoft.WindowsAppRuntime.1.2',
    'Microsoft.WindowsAppRuntime.1.4',
    'Microsoft.Windows.OOBENetworkCaptivePortal',
    'Microsoft.Windows.Search'
)

# Combine the two arrays
$appstoignore = $WhitelistedApps += $NonRemovable

# Bloat list for future reference
$Bloatware = @(
    #Unnecessary Windows 10/11 AppX Apps
    "*ActiproSoftwareLLC*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    "*BubbleWitch3Saga*"
    "*CandyCrush*"
    "*DevHome*"
    "*Disney*"
    "*Dolby*"
    "*Duolingo-LearnLanguagesforFree*"
    "*EclipseManager*"
    "*Facebook*"
    "*Flipboard*"
    "*gaming*"
    "*Minecraft*"
    "*Office*"
    "*PandoraMediaInc*"
    "*Royal Revolt*"
    "*Speed Test*"
    "*Spotify*"
    "*Sway*"
    "*Twitter*"
    "*Wunderlist*"
    "AD2F1837.HPPrinterControl"
    "AppUp.IntelGraphicsExperience"
    "C27EB4BA.DropboxOEM*"
    "Disney.37853FC22B2CE"
    "DolbyLaboratories.DolbyAccess"
    "DolbyLaboratories.DolbyAudio"
    "E0469640.SmartAppearance"
    "Microsoft.549981C3F5F10"
    "Microsoft.AV1VideoExtension"
    "Microsoft.BingNews"
    "Microsoft.BingSearch"
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.GamingApp"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftEdge.Stable"
    "Microsoft.MicrosoftJournal"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.MPEG2VideoExtension"
    "Microsoft.News"
    "Microsoft.Office.Lens"
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.PowerAutomateDesktopCopilotPlugin"
    "Microsoft.Print3D"
    "Microsoft.RemoteDesktop"
    "Microsoft.SkypeApp"
    "Microsoft.SysinternalsSuite"
    "Microsoft.Teams"
    "Microsoft.Windows.DevHome"
    "Microsoft.WindowsAlarms"
    "Microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxGamingOverlay_5.721.10202.0_neutral_~_8wekyb3d8bbwe"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftCorporationII.MicrosoftFamily"
    "MicrosoftCorporationII.QuickAssist"
    "MicrosoftWindows.CrossDevice"
    "MirametrixInc.GlancebyMirametrix"
    "RealtimeboardInc.RealtimeBoard"
    "SpotifyAB.SpotifyMusic"
    "5A894077.McAfeeSecurity"
    "5A894077.McAfeeSecurity_2.1.27.0_x64__wafk5atnkzcwy"
    #Optional: Typically not removed but you can if you need to for some reason
    #"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
    #"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
    "*Microsoft.BingWeather*"
    #"*Microsoft.MSPaint*"
    #"*Microsoft.MicrosoftStickyNotes*"
    #"*Microsoft.Windows.Photos*"
    #"*Microsoft.WindowsCalculator*"
    #"Microsoft.Office.Todo.List"
    #"Microsoft.Whiteboard"
    #"Microsoft.WindowsCamera"
    #"Microsoft.WindowsSoundRecorder"
    #"Microsoft.YourPhone"
    #"Microsoft.Todos"
    #"MSTeams"
    #"Microsoft.PowerAutomateDesktop"
    #"MicrosoftWindows.Client.WebExperience"
)

$provisioned = Get-AppxProvisionedPackage -Online | Where-Object {
    $_.DisplayName -in $Bloatware -and $_.DisplayName -notin $appstoignore -and $_.DisplayName `
        -notlike 'MicrosoftWindows.Voice*' -and $_.DisplayName -notlike 'Microsoft.LanguageExperiencePack*' `
        -and $_.DisplayName -notlike 'MicrosoftWindows.Speech*' `
}
foreach ($appxprov in $provisioned) {
    $packagename = $appxprov.PackageName
    $displayname = $appxprov.DisplayName
    try {
        Remove-AppxProvisionedPackage -PackageName $packagename -Online -ErrorAction SilentlyContinue | out-null
        write-output "Removed $displayname AppX Provisioning Package"
    }
    catch {
        write-output "Unable to remove $displayname AppX Provisioning Package"
    }
}

$appxinstalled = Get-AppxPackage -AllUsers | Where-Object {
    $_.Name -in $Bloatware -and $_.Name -notin $appstoignore -and $_.Name `
    -notlike 'MicrosoftWindows.Voice*' -and $_.Name -notlike 'Microsoft.LanguageExperiencePack*' `
    -and $_.Name -notlike 'MicrosoftWindows.Speech*' `
}
foreach ($appxapp in $appxinstalled) {
    $packagename = $appxapp.PackageFullName
    $displayname = $appxapp.Name
    try {
        Remove-AppxPackage -Package $packagename -AllUsers -ErrorAction SilentlyContinue | out-null
        write-output "Removed $displayname AppX Package"
    }
    catch {
        write-output "$displayname AppX Package does not exist"
    }
}

Write-Output "Configuring registry to prevent bloatware apps from returning"
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath | out-null
}
Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1  | out-null
If (!(Test-Path $registryOEM)) {
    New-Item $registryOEM | out-null
}
Set-ItemProperty $registryOEM "FeatureManagementEnabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "OemPreInstalledAppsEnabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "PreInstalledAppsEnabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "SilentInstalledAppsEnabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "ContentDeliveryAllowed" -Value 0 | out-null
Set-ItemProperty $registryOEM "PreInstalledAppsEverEnabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "SubscribedContentEnabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "SubscribedContent-338388Enabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "SubscribedContent-338389Enabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "SubscribedContent-314559Enabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "SubscribedContent-338387Enabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "SubscribedContent-338393Enabled" -Value 0 | out-null
Set-ItemProperty $registryOEM "SystemPaneSuggestionsEnabled" -Value 0 | out-null

If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore")) {
    New-Item "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" | out-null
}
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "AutoDownload" 2 | out-null

# Prevents "Suggested Applications" returning
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
    New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" | out-null
}
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
    "DisableWindowsConsumerFeatures" 1 | out-null

