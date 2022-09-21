
# Win 10 specific tweaks
function disableNewsandInterests {
    if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0
    Set-ItemProperty -Path  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2
}

function removeMeetNowButtonFromTaskbar {
    if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideMeetNow" -Type DWord -Value 1
}

function main {
    createRestorePoint -Description "Fresh Install"
    # essential
    Write-Host "Set essential settings:"
    removeBloatware
    privacyTweaks
    disableCortana
    disableWebsearchInStartMenu
    # Win 10 specific
    disableNewsandInterests
    removeMeetNowButtonFromTaskbar
    # tweaks
    Write-Host "Tweak additional settings..."
    setComputerName
    setExecutionPolicy
    fileExplorerTweaks
    syncWindowsTerminalSettings
    # winget
    installWinget
    installWingetPackages
    createRestorePoint -Description "Clean Install After Setup Script"
}

#Requires -RunAsAdministrator
main
