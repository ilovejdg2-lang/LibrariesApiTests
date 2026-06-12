param(
    [string]$PublishSettingsPath = ""
)

$ErrorActionPreference = "Stop"
$projectDir = Resolve-Path "$PSScriptRoot\.."
$projectFile = Join-Path $projectDir "HackerRank1.csproj"
$profilesDir = Join-Path $projectDir "Properties\PublishProfiles"

if ([string]::IsNullOrWhiteSpace($PublishSettingsPath)) {
    $PublishSettingsPath = Get-ChildItem $profilesDir -Filter *.publishSettings -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
}

if (-not (Test-Path $PublishSettingsPath)) {
    throw "Coloca tu archivo .publishSettings en: $profilesDir"
}

[xml]$profile = Get-Content $PublishSettingsPath
$publishProfile = $profile.publishData.publishProfile
$password = $publishProfile.userPWD

if ([string]::IsNullOrWhiteSpace($password)) {
    throw "El publishSettings no contiene userPWD."
}

$publishDir = Join-Path $env:TEMP "HackerRank1-examen-monsterasp-publish"
if (Test-Path $publishDir) { Remove-Item $publishDir -Recurse -Force }
New-Item -ItemType Directory -Path $publishDir -Force | Out-Null

Write-Host "Compilando HackerRank1 (Release, win-x86) ..."
dotnet publish $projectFile -c Release -o $publishDir --runtime win-x86 --self-contained false
if ($LASTEXITCODE -ne 0) { throw "dotnet publish fallo con codigo $LASTEXITCODE" }

$msdeployCandidates = @(
    "${env:ProgramFiles}\IIS\Microsoft Web Deploy V3\msdeploy.exe",
    "${env:ProgramFiles(x86)}\IIS\Microsoft Web Deploy V3\msdeploy.exe"
)
$msdeploy = $msdeployCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $msdeploy) {
    throw "No se encontro msdeploy.exe. Instala Web Deploy 3.x o publica desde Visual Studio con el perfil WebDeploy."
}

$siteName = $publishProfile.msdeploySite
$server = $publishProfile.publishUrl

Write-Host "Subiendo a $($publishProfile.destinationAppUrl) ..."
$destUrl = "https://${server}:8172/msdeploy.axd?site=$siteName"
& $msdeploy -verb:sync `
    -source:contentPath="$publishDir" `
    -dest:contentPath="$siteName",computerName="$destUrl",userName="$($publishProfile.userName)",password="$password",authType="Basic",includeAcls="False" `
    -allowUntrusted `
    -disableLink:AppPoolExtension `
    -disableLink:ContentExtension `
    -disableLink:CertificateExtension `
    -enableRule:AppOffline `
    -retryAttempts:3
if ($LASTEXITCODE -ne 0) { throw "msdeploy fallo con codigo $LASTEXITCODE" }

Write-Host "Publicacion completada: $($publishProfile.destinationAppUrl)"
