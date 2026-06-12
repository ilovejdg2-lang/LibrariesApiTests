param(
    [Parameter(Mandatory = $true)]
    [string]$PublishDir,

    [Parameter(Mandatory = $true)]
    [string]$WebsiteName,

    [Parameter(Mandatory = $true)]
    [string]$ServerComputerName,

    [Parameter(Mandatory = $true)]
    [string]$ServerUsername,

    [Parameter(Mandatory = $true)]
    [string]$ServerPassword
)

$ErrorActionPreference = 'Stop'

$publishPath = (Resolve-Path $PublishDir).Path
$siteName = $WebsiteName.Trim()
$serverInput = $ServerComputerName.Trim().TrimEnd('/')

if ($serverInput -match '^https?://') {
    $deployHost = ([Uri]$serverInput).Host
}
else {
    $deployHost = ($serverInput -split ':')[0]
}

if ([string]::IsNullOrWhiteSpace($deployHost)) {
    throw 'SERVER_COMPUTER_NAME invalido. Ejemplo: https://site73835.siteasp.net:8172'
}

$msdeployCandidates = @(
    "${env:ProgramFiles}\IIS\Microsoft Web Deploy V3\msdeploy.exe",
    "${env:ProgramFiles(x86)}\IIS\Microsoft Web Deploy V3\msdeploy.exe"
)
$msdeploy = $msdeployCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $msdeploy) {
    throw 'No se encontro msdeploy.exe. Instala Web Deploy 3.x en el runner.'
}

$destUrl = "https://${deployHost}:8172/msdeploy.axd?site=$siteName"
Write-Host "MSDeploy: $siteName -> https://${deployHost}:8172"
Write-Host "Origen: $publishPath"

& $msdeploy -verb:sync `
    "-source:contentPath=$publishPath" `
    "-dest:contentPath=$siteName,computerName=$destUrl,userName=$ServerUsername,password=$ServerPassword,authType=Basic,includeAcls=False" `
    -allowUntrusted `
    -disableLink:AppPoolExtension `
    -disableLink:ContentExtension `
    -disableLink:CertificateExtension `
    -enableRule:AppOffline `
    -retryAttempts:3

if ($LASTEXITCODE -ne 0) {
    throw "msdeploy fallo con codigo $LASTEXITCODE"
}

Write-Host 'Deploy completado.'
