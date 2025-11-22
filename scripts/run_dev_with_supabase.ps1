#!/usr/bin/env pwsh
<#
Runs the Flutter app in Chrome using SUPABASE_URL and SUPABASE_ANON_KEY defined in a local `.env` file.
Usage:
  1. Copy `.env.example` to `.env` and fill values.
  2. Run this script from the project root in PowerShell:
     pwsh .\scripts\run_dev_with_supabase.ps1
#>

Set-StrictMode -Version Latest
$envFile = Join-Path $PSScriptRoot '..\.env'
#!/usr/bin/env pwsh
<#
Runs the Flutter app in Chrome using SUPABASE_URL and SUPABASE_ANON_KEY defined in a local `.env` file.
This script reads `.env` (ignored by git), extracts SUPABASE_* values and launches
`flutter run` passing them as `--dart-define` arguments. It uses Start-Process to
avoid quoting edge-cases and returns the flutter exit code.

Usage:
  1. Copy `.env.example` to `.env` and fill values.
  2. From the project root run (PowerShell):
   pwsh .\scripts\run_dev_with_supabase.ps1
#>

Set-StrictMode -Version Latest

$envFile = Join-Path $PSScriptRoot '..\.env'
if (-not (Test-Path $envFile)) {
  Write-Host ".env file not found at path: $envFile" -ForegroundColor Yellow
  Write-Host "Current script folder: $PSScriptRoot" -ForegroundColor Yellow
  Write-Host "Make sure you ran this script from the project root (pwsh .\scripts\run_dev_with_supabase.ps1)" -ForegroundColor Yellow
  exit 1
}

# Read .env lines, ignore empty lines and comments. Allow quoted values.
$lines = Get-Content $envFile | Where-Object { $_ -and -not ($_.TrimStart().StartsWith('#')) }
Write-Host "Read $($lines.Count) non-empty lines from $envFile" -ForegroundColor DarkCyan

$supabaseUrl = $null
$supabaseAnonKey = $null
$supabaseBucket = $null

foreach ($line in $lines) {
  $parts = $line -split '=', 2
  if ($parts.Count -ne 2) { continue }
  $key = $parts[0].Trim()
  $val = $parts[1].Trim()
  # Remove surrounding quotes if present
  if ($val.StartsWith('"') -and $val.EndsWith('"')) { $val = $val.Substring(1, $val.Length - 2) }
  if ($val.StartsWith("'") -and $val.EndsWith("'")) { $val = $val.Substring(1, $val.Length - 2) }

  switch ($key) {
    'SUPABASE_URL' { $supabaseUrl = $val }
    'SUPABASE_ANON_KEY' { $supabaseAnonKey = $val }
    'SUPABASE_BUCKET' { $supabaseBucket = $val }
    default { }
  }
}

if ([string]::IsNullOrEmpty($supabaseUrl) -or [string]::IsNullOrEmpty($supabaseAnonKey)) {
  Write-Host "Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env" -ForegroundColor Red
  exit 1
}

Write-Host "Starting Flutter with Supabase env..." -ForegroundColor Green
Write-Host "SUPABASE_URL: $supabaseUrl" -ForegroundColor DarkCyan
Write-Host "SUPABASE_BUCKET: $([string]::IsNullOrEmpty($supabaseBucket) ? '(not set)' : $supabaseBucket)" -ForegroundColor DarkCyan

# Build argument list for Start-Process to avoid complex quoting
$args = @('run', '-d', 'chrome')
$args += "--dart-define=SUPABASE_URL=$supabaseUrl"
$args += "--dart-define=SUPABASE_ANON_KEY=$supabaseAnonKey"
if (-not [string]::IsNullOrEmpty($supabaseBucket)) {
  $args += "--dart-define=SUPABASE_BUCKET=$supabaseBucket"
}

Write-Host "Invoking: flutter $($args -join ' ')" -ForegroundColor Cyan

# Start flutter in the same window and wait for it to finish
try {
  $proc = Start-Process -FilePath flutter -ArgumentList $args -NoNewWindow -Wait -PassThru
  if ($null -eq $proc) {
    Write-Host "Failed to start 'flutter'. Is Flutter installed and in PATH?" -ForegroundColor Red
    exit 1
  }
  if ($proc.ExitCode -ne 0) {
    Write-Host "flutter exited with code $($proc.ExitCode)" -ForegroundColor Red
    exit $proc.ExitCode
  }
} catch {
  Write-Host "Error launching flutter:" -ForegroundColor Red
  Write-Host $_.Exception.Message -ForegroundColor Red
  if ($_.Exception.InnerException) { Write-Host $_.Exception.InnerException.Message -ForegroundColor Red }
  exit 1
}
