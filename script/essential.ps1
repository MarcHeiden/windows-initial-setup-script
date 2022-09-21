function removeBloatware {
    $bloatware = @(
        "Microsoft.BingFinance"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingTranslator"
        "Microsoft.BingWeather"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingTravel"
        "Microsoft.MinecraftUWP"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.Sway"
        "Microsoft.People"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.MicrosoftStickyNotes"
        "*Microsoft.Advertising.Xaml*"
        "Microsoft.Todos"
        "Microsoft.PowerAutomateDesktop"
        "MicrosoftTeams"
        "Microsoft.MixedReality.Portal"

        # Sponsored/featured apps
        "*EclipseManager*"
        "*ActiproSoftwareLLC*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Duolingo-LearnLanguagesforFree*"
        "*PandoraMediaInc*"
        "*CandyCrush*"
        "*BubbleWitch3Saga*"
        "*Wunderlist*"
        "*Flipboard*"
        "*Twitter*"
        "*Facebook*"
        "*Royal Revolt*"
        "*Viber*"
        "*ACGMediaPlayer*"
        "*Netflix*"
        "*OneCalendar*"
        "*LinkedInforWindows*"
        "*HiddenCityMysteryofShadows*"
        "*Hulu*"
        "*HiddenCity*"
        "*AdobePhotoshopExpress*"
        "*PicsArt*"
        "*Instagram*"
        "*Xing*"
        "*Sound Blaster Connect*"

        #"Microsoft.3DBuilder"
        #"Microsoft.Microsoft3DViewer"
        #"Microsoft.AppConnector"
        #"Microsoft.WindowsReadingList"
        #"Microsoft.NetworkSpeedTest"
        #"Microsoft.Office.OneNote"
        #"Microsoft.OneConnect"
        #"Microsoft.Whiteboard"
        #"Microsoft.WindowsAlarms"
        #"microsoft.windowscommunicationsapps"
        #"Microsoft.WindowsPhone"
        #"Microsoft.WindowsFeedbackHub"
        #"Microsoft.ConnectivityStore"
        #"Microsoft.ScreenSketch"
        #"Microsoft.YourPhone"
        #"Microsoft.MicrosoftOfficeHub"
        #"*Microsoft.MSPaint*"
        #"*Microsoft.Windows.Photos*"
        #"*Microsoft.WindowsCalculator*"
        #"*Microsoft.WindowsStore*"
        #"Microsoft.WindowsCamera"
        #"Microsoft.CommsPhone"
        #"Microsoft.XboxApp"
        #"Microsoft.Xbox.TCUI"
        #"Microsoft.XboxGameOverlay"
        #"Microsoft.XboxGameCallableUI"
        #"Microsoft.XboxSpeechToTextOverlay"
        #"Microsoft.XboxIdentityProvider"
        #"Microsoft.GamingServices"
        #"Microsoft.ZuneMusic"
        #"Microsoft.ZuneVideo"
        #"Microsoft.GamingApp"
    )
    Write-Host "Try to remove Bloatware..."
    foreach ($app in $bloatware) {
        try {
            Get-AppxPackage -Name $app | Remove-AppxPackage 
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online | Out-Null
        }
        catch {
            Write-Host $error
        }
    }

    #Prevents bloatware applications from returning and removes Start Menu suggestions               
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    if (!(Test-Path $registryPath)) { 
        New-Item $registryPath | Out-Null
    }
    Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

    if (!(Test-Path $registryOEM)) {
        New-Item $registryOEM | Out-Null
    }
    Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
    Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
    Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0   
}

function privacyTweaks {
    Write-Host "Tweak Privacy Settings..."
    # Disabling Telemetry
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type Dword -Value 0

    # Disabling Tailored Experiences
    if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"  | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1

    # Disabling Advertising ID
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1

    #Disabling Location Tracking
    if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
    if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0

    # Disabling Activity History
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0

    # Stopping and disabling Diagnostics Tracking Service
    Stop-Service "DiagTrack" -WarningAction SilentlyContinue
    Set-Service "DiagTrack" -StartupType Disabled
}

function disableCortana {
    Write-Host "Disable Cortana..."
    $cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
    $cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
    $cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    if (!(Test-Path $cortana1)) {
        New-Item $cortana1 | Out-Null
    }
    Set-ItemProperty $cortana1 AcceptedPrivacyPolicy -Value 0 
    if (!(Test-Path $cortana2)) {
        New-Item $cortana2 | Out-Null
    }
    Set-ItemProperty $cortana2 RestrictImplicitTextCollection -Value 1 
    Set-ItemProperty $cortana2 RestrictImplicitInkCollection -Value 1 
    if (!(Test-Path $cortana3)) {
        New-Item $cortana3 | Out-Null
    }
    Set-ItemProperty $cortana3 HarvestContacts -Value 0     

    #Stops Cortana from being used as part of your Windows search function
    $search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows search"
    if (Test-Path $search) {
        Set-ItemProperty $search AllowCortana -Value 0 
    }
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\search" CortanaConsent -Value 0
}

function disableWebsearchInStartMenu {
    if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" | Out-Null
    }
    Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Explorer" DisableSearchBoxSuggestions -Value 1
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\search" BingSearchEnabled -Value 0 
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\search" AllowSearchToUseLocation -Value 0
    $webSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows search"
    if (!(Test-Path $webSearch)) {
        New-Item $webSearch -Force | Out-Null
    }
    Set-ItemProperty $webSearch DisablewebSearch -Value 1    
}

function createRestorePoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $description
    )
    Write-Host "Create Restore Point..."
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" SystemRestorePointCreationFrequency -Value 0
    Enable-ComputerRestore -Drive "C:\"
    Checkpoint-Computer -Description "$description" -RestorePointType "MODIFY_SETTINGS"
    Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" SystemRestorePointCreationFrequency
}