param(
    [string]$PublishSettingsPath = "",
    [switch]$BuildOnly
)

$ErrorActionPreference = 'Stop'

$projectDir = Resolve-Path "$PSScriptRoot\.."
$envFile = Join-Path $projectDir '.env'

function Import-EnvFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        throw "No existe $Path"
    }
    Get-Content $Path | ForEach-Object {
        if ($_ -match '^\s*#' -or [string]::IsNullOrWhiteSpace($_)) { return }
        $sep = $_.IndexOf('=')
        if ($sep -le 0) { return }
        $key = $_.Substring(0, $sep).Trim()
        $value = $_.Substring($sep + 1).Trim()
        if ([string]::IsNullOrEmpty($key)) { return }
        [Environment]::SetEnvironmentVariable($key, $value, 'Process')
    }
}

Import-EnvFile $envFile
[Environment]::SetEnvironmentVariable('ASPNETCORE_ENVIRONMENT', 'Production', 'Process')
& "$PSScriptRoot\verify-deploy-secrets.ps1"

$publishDir = Join-Path $env:TEMP 'HackerRank1-monsterasp-deploy'
& "$PSScriptRoot\package-for-monster.ps1" -PublishDir $publishDir | Out-Null

if ($BuildOnly) { return }

$websiteName = $env:WEBSITE_NAME
$serverComputerName = $env:SERVER_COMPUTER_NAME
$serverUsername = $env:SERVER_USERNAME
$serverPassword = $env:SERVER_PASSWORD

if ([string]::IsNullOrWhiteSpace($websiteName) -or [string]::IsNullOrWhiteSpace($serverPassword)) {
    $profilesDir = Join-Path $projectDir 'Properties\PublishProfiles'
    if ([string]::IsNullOrWhiteSpace($PublishSettingsPath)) {
        $PublishSettingsPath = Get-ChildItem $profilesDir -Filter *.publishSettings -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName
    }
    if ($PublishSettingsPath -and (Test-Path $PublishSettingsPath)) {
        [xml]$profile = Get-Content $PublishSettingsPath
        $pp = $profile.publishData.publishProfile
        if ([string]::IsNullOrWhiteSpace($websiteName)) { $websiteName = $pp.msdeploySite }
        if ([string]::IsNullOrWhiteSpace($serverComputerName)) { $serverComputerName = $pp.publishUrl }
        if ([string]::IsNullOrWhiteSpace($serverUsername)) { $serverUsername = $pp.userName }
        if ([string]::IsNullOrWhiteSpace($serverPassword)) { $serverPassword = $pp.userPWD }
    }
}

& "$PSScriptRoot\deploy-msdeploy.ps1" `
    -PublishDir $publishDir `
    -WebsiteName $websiteName `
    -ServerComputerName $serverComputerName `
    -ServerUsername $serverUsername `
    -ServerPassword $serverPassword
