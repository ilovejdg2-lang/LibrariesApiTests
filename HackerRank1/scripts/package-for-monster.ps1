param(
    [string]$PublishDir = ''
)

$ErrorActionPreference = 'Stop'

$projectDir = Resolve-Path "$PSScriptRoot\.."
$projectFile = Join-Path $projectDir 'HackerRank1.csproj'

if ([string]::IsNullOrWhiteSpace($PublishDir)) {
    $base = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } else { $env:TEMP }
    $PublishDir = Join-Path $base 'HackerRank1-monsterasp-deploy'
}

if (Test-Path $PublishDir) {
    Remove-Item $PublishDir -Recurse -Force
}
New-Item -ItemType Directory -Path $PublishDir -Force | Out-Null

dotnet publish $projectFile -c Release -r win-x86 --self-contained false -o $PublishDir | Out-Host
if ($LASTEXITCODE -ne 0) {
    throw "dotnet publish fallo con codigo $LASTEXITCODE"
}

& "$PSScriptRoot\write-deploy-env.ps1" -PublishDir $PublishDir
New-Item -ItemType Directory -Path (Join-Path $PublishDir 'logs') -Force | Out-Null
