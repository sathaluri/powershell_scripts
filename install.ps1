# Install Chocolatey
if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Fetch the list of software to install from config.ini
$configUrl = "https://raw.githubusercontent.com/sathaluri/powershell_scripts/main/config.ini"
$softwareList = Invoke-WebRequest -Uri $configUrl -UseBasicParsing | Select-Object -ExpandProperty Content | Out-String | ConvertFrom-StringData

# Install each software if it is not already installed
foreach ($software in $softwareList.Keys) {
    if (-not(Get-Command $software -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $($software)..."
        choco install $software -y
    } else {
        Write-Host "$($software) is already installed."
    }
}


