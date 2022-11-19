function fileExplorerTweaks {
    #Showing file extensions
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
    #Showing hidden files
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
    # Change default view to This PC
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
}

function setComputerName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)] [switch] $isLaptop = $false
    )
    $build = [System.Environment]::OSVersion.Version.Build
    if ($isLaptop) {
        $name = "Laptop"
    }
    else {
        $name = "PC"
    }
    Write-Host "Set Computer Name to $name-WIN-$build..."
    Rename-Computer -NewName "$name-WIN-$build"
}

function syncWindowsTerminalSettings {
    Write-Host "Sync Windows Terminal Settings..."
    try {
        Remove-Item -Path "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" -Force -Recurse -ErrorAction Stop
        New-Item -ItemType SymbolicLink -Path "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" -Target "$Env:OneDrive\Windows Terminal Sync" -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Host "Windows Terminal Settings Sync: $error"    
    }
}

function setExecutionPolicy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)] [string] $policy = "RemoteSigned"
    )
    Write-Host "Set Execution Policy to $policy..."
    Set-ExecutionPolicy $policy
}