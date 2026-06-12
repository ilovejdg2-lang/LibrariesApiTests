$ErrorActionPreference = 'Stop'

$required = @(
    'CONNECTION_STRING',
    'DB_PASSWORD',
    'JWT_SECRET_KEY',
    'JWT_ISSUER',
    'JWT_AUDIENCE',
    'CORS_ORIGINS',
    'WEBSITE_NAME',
    'SERVER_COMPUTER_NAME',
    'SERVER_USERNAME',
    'SERVER_PASSWORD'
)

$missing = @()
foreach ($key in $required) {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($key))) {
        $missing += $key
    }
}

if ($missing.Count -gt 0) {
    throw "Faltan variables: $($missing -join ', ')"
}
