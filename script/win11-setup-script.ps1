function main {
    # Import functions
    . $PSScriptRoot\essential.ps1
    . $PSScriptRoot\tweaks.ps1
    . $PSScriptRoot\winget.ps1
    
    createRestorePoint -Description "Fresh Install"
    # essential
    Write-Host "Set essential settings:"
    removeBloatware
    privacyTweaks
    disableCortana
    disableWebsearchInStartMenu
    # tweaks
    Write-Host "Tweak additional settings..."
    setComputerName
    setExecutionPolicy
    fileExplorerTweaks
    syncWindowsTerminalSettings
    # winget
    # No need to install winget in Win 11 because it is already installed
    installWingetPackages
    createRestorePoint -Description "Clean Install After Setup Script"
}

#Requires -RunAsAdministrator
main
