#!/usr/bin/env pwsh
<#
Runs the Flutter app in Chrome using SUPABASE_URL and SUPABASE_ANON_KEY defined in a local `.env` file.
Usage:
  1. Copy `.env.example` to `.env` and fill values.
  2. Run this script from the project root in PowerShell:
     pwsh .\scripts\run_dev_with_supabase.ps1
#>

Set-StrictMode -Version Latest
$envFile = Join-Path $PSScriptRoot '..\.env' | Resolve-Path -Relative
if (-not (Test-Path $envFile)) {
  Write-Host ".env file not found. Copy .env.example to .env and fill SUPABASE_URL and SUPABASE_ANON_KEY." -ForegroundColor Yellow
  exit 1
}

$lines = Get-Content $envFile | Where-Object {$_ -and -not ($_.TrimStart().StartsWith('#'))}
$supabaseUrl = $null
$supabaseAnonKey = $null
foreach ($line in $lines) {
  $parts = $line -split '=', 2
  if ($parts.Count -ne 2) { continue }
  $key = $parts[0].Trim()
  $val = $parts[1].Trim()
  if ($key -eq 'SUPABASE_URL') { $supabaseUrl = $val }
  if ($key -eq 'SUPABASE_ANON_KEY') { $supabaseAnonKey = $val }
}

if ([string]::IsNullOrEmpty($supabaseUrl) -or [string]::IsNullOrEmpty($supabaseAnonKey)) {
  Write-Host "Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env" -ForegroundColor Red
  exit 1
}

Write-Host "Starting Flutter with Supabase env..." -ForegroundColor Green
flutter run -d chrome --dart-define=SUPABASE_URL=$supabaseUrl --dart-define=SUPABASE_ANON_KEY=$supabaseAnonKey
