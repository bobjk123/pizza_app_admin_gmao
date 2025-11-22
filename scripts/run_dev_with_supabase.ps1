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
if (-not (Test-Path $envFile)) {
  Write-Host ".env file not found. Copy .env.example to .env and fill SUPABASE_URL and SUPABASE_ANON_KEY." -ForegroundColor Yellow
  exit 1
}

# Read .env lines, ignore empty lines and comments. Allow quoted values.
$lines = Get-Content $envFile | Where-Object { $_ -and -not ($_.TrimStart().StartsWith('#')) }
$supabaseUrl = $null
$supabaseAnonKey = $null
$supabaseBucket = $null
foreach ($line in $lines) {
  $parts = $line -split '=', 2
  if ($parts.Count -ne 2) { continue }
  $key = $parts[0].Trim()
  $val = $parts[1].Trim()
  # Remove surrounding quotes if present
  $val = $val.Trim('"').Trim("'")
  if ($key -eq 'SUPABASE_URL') { $supabaseUrl = $val }
  if ($key -eq 'SUPABASE_ANON_KEY') { $supabaseAnonKey = $val }
  if ($key -eq 'SUPABASE_BUCKET') { $supabaseBucket = $val }
}

if ([string]::IsNullOrEmpty($supabaseUrl) -or [string]::IsNullOrEmpty($supabaseAnonKey)) {
  Write-Host "Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env" -ForegroundColor Red
  exit 1
}

Write-Host "Starting Flutter with Supabase env..." -ForegroundColor Green

# Build dart-define arguments, quoting values to be safe
$urlArg = "--dart-define=SUPABASE_URL=\"$supabaseUrl\""
$keyArg = "--dart-define=SUPABASE_ANON_KEY=\"$supabaseAnonKey\""
$bucketArg = ""
if (-not [string]::IsNullOrEmpty($supabaseBucket)) {
  $bucketArg = " --dart-define=SUPABASE_BUCKET=\"$supabaseBucket\""
}

$cmd = "flutter run -d chrome $urlArg $keyArg$bucketArg"
Write-Host $cmd -ForegroundColor Cyan
Invoke-Expression $cmd
