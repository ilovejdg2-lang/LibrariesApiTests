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

$lines = @(
    '# Generado en deploy — no commitear',
    'ASPNETCORE_ENVIRONMENT=Production'
)

foreach ($key in $required) {
    $value = [Environment]::GetEnvironmentVariable($key)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Falta el secret de GitHub Actions: $key"
    }
    $lines += "$key=$value"
}

$cors = [Environment]::GetEnvironmentVariable('CORS_ORIGINS')
if (-not [string]::IsNullOrWhiteSpace($cors)) {
    $lines += "CORS_ORIGINS=$cors"
}

$envPath = Join-Path $PublishDir '.env'
$lines | Set-Content -Path $envPath -Encoding UTF8
Write-Host "Archivo .env creado en el paquete de publicacion."
