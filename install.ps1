# Install Chocolatey
if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
}

# Fetch the list of software to install from config.ini
$configUrl = "https://raw.githubusercontent.com/sathaluri/powershell_scripts/main/config.ini"
$softwareList = Invoke-WebRequest -Uri $configUrl -UseBasicParsing | Select-Object -ExpandProperty Content | Out-String | ConvertFrom-StringData

# Install each software if it is not already installed
foreach ($software in $softwareList.Keys) {
    $install = $softwareList[$software]
    
    if (-not (Get-Command $software -ErrorAction SilentlyContinue)) {
        if ($install -eq "true") {
            Write-Host "Installing $software..."
            choco install $software -y
        } else {
            Write-Host "$software is not set for installation."
        }
    } else {
        Write-Host "$software is already installed."
    }
}

# Remove downloads
if (Test-Path "$env:TEMP\chocolatey") {
    Remove-Item -Path "$env:TEMP\chocolatey" -Recurse
}
