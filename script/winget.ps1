function installWinget {
    try {
        # Install winget and software packages
        Write-Host "Install winget..."
        $asset = Invoke-RestMethod -Method Get -Uri 'https://api.github.com/repos/microsoft/winget-cli/releases/latest' | ForEach-Object assets | Where-Object name -like "*.msixbundle"
        $output = $PSScriptRoot + "\winget-latest.appxbundle"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $output | Out-Null

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
}

function installWingetPackages {
    Write-Host "Install winget packages..."
    try {
        Invoke-Expression "winget import -i $PSScriptRoot\winget-packages.json --ignore-versions" -ErrorAction Stop
    }
    catch {
        Write-Host "winget packages installation: $error"   
    }
}