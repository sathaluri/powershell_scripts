$configUrl = "https://raw.githubusercontent.com/sathaluri/powershell_scripts/main/config.ini"

$config = Invoke-WebRequest -Uri $configUrl | Select-Object -ExpandProperty Content | Out-String | ConvertFrom-StringData

switch -Regex (Get-WmiObject -Class Win32_OperatingSystem).Caption {
    'Mac'     { $os = 'mac'; $packages = $config.$os }
    'Windows' { $os = 'windows'; $packages = $config.$os }
    Default   { Write-Error 'Unsupported operating system'; exit }
}

foreach ($package in $packages.GetEnumerator()) {
    $name = $package.Name
    $installed = Get-Package -Name $name -ErrorAction SilentlyContinue
    if (-not $installed) {
        Write-Host "Installing $name"
        Install-Package -Name $name -Force
    } else {
        Write-Host "$name is already installed"
    }
}
