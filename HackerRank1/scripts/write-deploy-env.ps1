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

# ── Recopilar valores ──────────────────────────────────────────────────────────
$secrets = @{}
foreach ($key in $required) {
    $value = [Environment]::GetEnvironmentVariable($key)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Falta el secret de GitHub Actions: $key"
    }
    $secrets[$key] = $value
}

$cors = [Environment]::GetEnvironmentVariable('CORS_ORIGINS')
if (-not [string]::IsNullOrWhiteSpace($cors)) {
    $secrets['CORS_ORIGINS'] = $cors
}

# ── 1. Escribir web.config con <environmentVariables> (método principal IIS) ──
$webConfigPath = Join-Path $PublishDir 'web.config'
[xml]$wc = Get-Content $webConfigPath -Raw

$envVarsNode = $wc.SelectSingleNode('//environmentVariables')

# Añadir cada secret como <environmentVariable name="..." value="...">
foreach ($entry in $secrets.GetEnumerator()) {
    $existing = $envVarsNode.SelectSingleNode("environmentVariable[@name='$($entry.Key)']")
    if ($existing) {
        $existing.SetAttribute('value', $entry.Value)
    } else {
        $el = $wc.CreateElement('environmentVariable')
        $el.SetAttribute('name',  $entry.Key)
        $el.SetAttribute('value', $entry.Value)
        $envVarsNode.AppendChild($el) | Out-Null
    }
}

$wc.Save($webConfigPath)
Write-Host "web.config actualizado con variables de entorno."

# ── 2. También escribir .env (fallback para desarrollo local) ─────────────────
$lines = @('# Generado en deploy — no commitear', 'ASPNETCORE_ENVIRONMENT=Production')
foreach ($entry in $secrets.GetEnumerator()) {
    $lines += "$($entry.Key)=$($entry.Value)"
}
$envPath = Join-Path $PublishDir '.env'
$lines | Set-Content -Path $envPath -Encoding UTF8
Write-Host "Archivo .env creado en el paquete de publicacion."
