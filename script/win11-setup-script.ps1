function install_winget {
    try {
        # Install winget and software packages
        Write-Host "Intstall winget..."
        $asset = Invoke-RestMethod -Method Get -Uri 'https://api.github.com/repos/microsoft/winget-cli/releases/latest' | ForEach-Object assets | Where-Object name -like "*.msixbundle"
        $output = $PSScriptRoot + "\winget-latest.appxbundle"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $output

        # Installing the winget package
        Add-AppxPackage -Path $output

        # Cleanup winget install package
        if (Test-Path -Path $output) {
            Remove-Item $output -Force -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Host "winget installation: $error"
    }
    finally {
        # Install winget packages
        Write-Host "Install winget packages..."
        try {
            Invoke-Expression "winget import -i $PSScriptRoot\winget-packages.json --ignore-versions" -ErrorAction Stop
        }
        catch {
            Write-Host "winget packages installation: $error"   
        }
    }
}
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
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online
        }
        catch {
            Write-Host $error
        }
    }

    #Prevents bloatware applications from returning and removes Start Menu suggestions               
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (!(Test-Path $registryPath)) { 
        New-Item $registryPath
    }
    Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

    If (!(Test-Path $registryOEM)) {
        New-Item $registryOEM
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
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type Dword -Value 0

    # Disabling Tailored Experiences
    If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1

    # Disabling Advertising ID
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1

    #Disabling Location Tracking
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
    IF (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Force | Out-Null
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
function additionalTweaks {
    Write-Host "Tweak additional settings..."
    #Disable News and Interests | No need in Windows 11
    #Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0

    #File Explorer Tweaks
    #Showing file extensions
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
    #Showing hidden files
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
    # Change default view to This PC
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1

    #Disables Web Search in Start Menu
    If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
    }
    Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Explorer" DisableSearchBoxSuggestions -Value 1
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0 
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" AllowSearchToUseLocation -Value 0
    $WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (!(Test-Path $WebSearch)) {
        New-Item $WebSearch
    }
    Set-ItemProperty $WebSearch DisableWebSearch -Value 1 

    #Stops Cortana from being used as part of your Windows Search Function
    $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (Test-Path $Search) {
        Set-ItemProperty $Search AllowCortana -Value 0 
    }
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" CortanaConsent -Value 0

    # Rename Computer Name
    $build = [System.Environment]::OSVersion.Version.Build
    Rename-Computer -NewName "PC-WIN-$build"

    # Windows Terminal Settings Sync
    try {
        Remove-Item -Path "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" -Force -Recurse -ErrorAction Stop
        New-Item -ItemType SymbolicLink -Path "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" -Target "$Env:OneDrive\Windows Terminal Sync" -ErrorAction Stop
    }
    catch {
        Write-Host "Windows Terminal Settings Sync: $error"    
    }

    # Set Execution Policy to RemoteSigned
    Set-ExecutionPolicy RemoteSigned
}
function disableCortana {
    Write-Host "Disabling Cortana..."
    $Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
    $Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
    $Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    If (!(Test-Path $Cortana1)) {
        New-Item $Cortana1
    }
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
    If (!(Test-Path $Cortana2)) {
        New-Item $Cortana2
    }
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
    If (!(Test-Path $Cortana3)) {
        New-Item $Cortana3
    }
    Set-ItemProperty $Cortana3 HarvestContacts -Value 0     
}
function createRestorePoint {
    param($description)
    Write-Host "Creating Restore Point"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" SystemRestorePointCreationFrequency -Value 0
    Enable-ComputerRestore -Drive "C:\"
    Checkpoint-Computer -Description "$description" -RestorePointType "MODIFY_SETTINGS"
    Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" SystemRestorePointCreationFrequency
}
function main {
    createRestorePoint "Fresh Install"
    removeBloatware
    privacyTweaks
    additionalTweaks
    disableCortana
    install_winget
    #createRestorePoint "Clean Install After Setup Script"
}

#Requires -RunAsAdministrator
main
