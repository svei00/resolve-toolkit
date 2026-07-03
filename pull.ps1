# Pull templates: Resolve AppData -> repo (excludes .bak backup files). Review with git diff afterwards.
$ErrorActionPreference = "Stop"
$repo = Join-Path $PSScriptRoot "templates\Edit"
$live = "C:\Users\svei\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Templates\Edit"

Copy-Item "$live\Generators\*.setting" "$repo\Generators\" -Force
Copy-Item "$live\Effects\*.setting" "$repo\Effects\" -Force
Copy-Item "$live\Generators\*.md" "$repo\Generators\" -Force -ErrorAction SilentlyContinue
Write-Host "Pulled from AppData. Run 'git diff' to review, then commit."
