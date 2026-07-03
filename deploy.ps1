# Deploy templates: repo -> Resolve AppData (with timestamped backup of current AppData templates)
$ErrorActionPreference = "Stop"
$repo = Join-Path $PSScriptRoot "templates\Edit"
$live = "C:\Users\svei\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Templates\Edit"
$backup = Join-Path $PSScriptRoot ("_backups\appdata-" + (Get-Date -Format "yyyyMMdd-HHmmss"))

New-Item -ItemType Directory -Force $backup | Out-Null
Copy-Item $live $backup -Recurse -Force
Copy-Item "$repo\Generators\*" "$live\Generators\" -Force
Copy-Item "$repo\Effects\*" "$live\Effects\" -Force
Write-Host "Deployed. Backup of previous AppData state: $backup"
Write-Host "RESTART DaVinci Resolve to see new/updated templates."
