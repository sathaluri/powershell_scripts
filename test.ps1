$os = switch -Regex (Get-WmiObject -Class Win32_OperatingSystem).Caption {
    'Mac' { 'mac' }
    'Windows' { 'windows' }
    default { throw "Unsupported operating system: $_" }
}

$configUrl = 'https://raw.githubusercontent.com/sathaluri/powershell_scripts/main/config.ini'
$config = Invoke-WebRequest -Uri $configUrl -UseBasicParsing | Select-Object -ExpandProperty Content | Out-String | ConvertFrom-StringData

$packages = $config.$os.GetEnumerator() | Where-Object { $_.Value -eq 'true' } | Select-Object -ExpandProperty Name

$extensionsUrl = 'https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery'
$extensionsBody = @{
    filters = @(
        @{
            criteria = @{
                filterType = 'tag'
                value = 'powershell'
            }
        }
    )
    flags = 'None'
}
$extensions = Invoke-WebRequest -Uri $extensionsUrl -Method Post -ContentType 'application/json' -Body ($extensionsBody | ConvertTo-Json) -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json

$featuresUrl = 'https://docs.microsoft.com/api/learn/features?api-version=2020-01-01'
$features = Invoke-WebRequest -Uri $featuresUrl -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json

$features | Where-Object { $packages -contains $_.id } | ForEach-Object {
    $extension = $extensions.results.extensions | Where-Object { $_.displayName -eq $_.displayName.Replace('Visual Studio Code', 'VS Code') } | Where-Object { $_.publisher.publisherName -eq $_.publisher.publisherName.Replace('Microsoft Corporation', 'Microsoft') } | Where-Object { $_.publisher.publisherName -eq $_.publisher.publisherName.Replace('Microsoft Corporation (ms-dotnettools)', 'Microsoft (ms-dotnettools)') } | Where-Object { $_.id -eq $_.id.Replace('ms-', '') } | Where-Object { $_.id -eq $_.id.Replace('vs-', '') } | Sort-Object -Property publishedDate -Descending | Select-Object -First 1
    if ($extension) {
        Install-VSCodeExtension -Name $extension.displayName -Force
    }
}
