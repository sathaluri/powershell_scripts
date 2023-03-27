# Install Chocolatey
if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
}

# Fetch the list of software to install from config.ini
$configUrl = "https://raw.githubusercontent.com/sathaluri/powershell_scripts/main/config.ini"
$softwareList = Invoke-WebRequest -Uri $configUrl | Select-Object -ExpandProperty Content | Out-String | ConvertFrom-StringData

# Install each software if it is not already installed
foreach ($software in $softwareList.Keys) {
    if (-not(Get-Command $software -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $($software)..."
        choco install $software -y
    } else {
        Write-Host "$($software) is already installed."
    }
}
