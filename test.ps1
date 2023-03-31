# Install Chocolatey
if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
}

# Fetch the list of software and Windows config to install from Github
$configUrl = "https://raw.githubusercontent.com/sathaluri/powershell_scripts/main/config.ini"
$allConfig = Invoke-WebRequest -Uri $configUrl -UseBasicParsing | Select-Object -ExpandProperty Content | Out-String | ConvertFrom-StringData

# Select only the [windows] section of the config
$windowsConfig = $allConfig.windows

# Install each software if it is not already installed
foreach ($software in $windowsConfig.software.Keys) {
    if (-not(Get-Command $software -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $($software)..."
        choco install $software -y
    } else {
        Write-Host "$($software) is already installed."
    }
}

# Install Visual Studio Code extensions
$extensionsUrl = $windowsConfig.vscode_extensions
$extensions = Invoke-WebRequest -Uri $extensionsUrl -UseBasicParsing | Select-Object -ExpandProperty Content | Out-String
$extensionsArray = $extensions -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
foreach ($extension in $extensionsArray) {
    if (-not(Get-Command code-insiders.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Visual Studio Code Insiders is not installed."
    } else {
        $result = code-insiders.exe --install-extension $extension
        if ($result) {
            Write-Host "Installed extension $($extension) for Visual Studio Code Insiders."
        } else {
            Write-Host "Failed to install extension $($extension) for Visual Studio Code Insiders."
        }
    }
}

# Enable Windows features
$featuresUrl = $windowsConfig.windows_features
$features = Invoke-WebRequest -Uri $featuresUrl -UseBasicParsing | Select-Object -ExpandProperty Content | Out-String
$featuresArray = $features -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
foreach ($feature in $featuresArray) {
    $result = Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
    if ($result) {
        Write-Host "Enabled Windows feature $($feature)."
    } else {
        Write-Host "Failed to enable Windows feature $($feature)."
    }
}
