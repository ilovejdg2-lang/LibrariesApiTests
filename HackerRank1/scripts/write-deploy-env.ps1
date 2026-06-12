param(
    [Parameter(Mandatory = $true)]
    [string]$PublishDir
)

$ErrorActionPreference = 'Stop'

$required = @(
    'CONNECTION_STRING',
    'DB_PASSWORD',
    'JWT_SECRET_KEY',
    'JWT_ISSUER',
    'JWT_AUDIENCE'
)

$secrets = @{}
foreach ($key in $required) {
    $value = [Environment]::GetEnvironmentVariable($key)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Falta la variable de entorno: $key"
    }
    $secrets[$key] = $value
}

$cors = [Environment]::GetEnvironmentVariable('CORS_ORIGINS')
if ([string]::IsNullOrWhiteSpace($cors)) {
    throw 'Falta la variable de entorno: CORS_ORIGINS'
}
$secrets['CORS_ORIGINS'] = $cors

$webConfigPath = Join-Path $PublishDir 'web.config'
[xml]$wc = Get-Content $webConfigPath -Raw
$envVarsNode = $wc.SelectSingleNode('//environmentVariables')

foreach ($entry in $secrets.GetEnumerator()) {
    $existing = $envVarsNode.SelectSingleNode("environmentVariable[@name='$($entry.Key)']")
    if ($existing) {
        $existing.SetAttribute('value', $entry.Value)
    } else {
        $el = $wc.CreateElement('environmentVariable')
        $el.SetAttribute('name', $entry.Key)
        $el.SetAttribute('value', $entry.Value)
        $envVarsNode.AppendChild($el) | Out-Null
    }
}

$wc.Save($webConfigPath)

$lines = @('ASPNETCORE_ENVIRONMENT=Production')
foreach ($entry in $secrets.GetEnumerator()) {
    $lines += "$($entry.Key)=$($entry.Value)"
}
$lines | Set-Content -Path (Join-Path $PublishDir '.env') -Encoding UTF8
