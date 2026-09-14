# Setup script for pi-dev profiles
# Installs npm dependencies in all .pi/npm directories

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "Installing pi extensions..."

# Find all package.json files inside .pi/npm directories
$packageFiles = Get-ChildItem -Path $ScriptDir -Recurse -Filter "package.json" |
    Where-Object { $_.FullName -match '\\.pi\\npm\\package\.json$' } |
    Sort-Object FullName

if ($packageFiles.Count -eq 0) {
    Write-Host "No .pi/npm directories found."
    exit 0
}

foreach ($pkg in $packageFiles) {
    $dir = $pkg.DirectoryName
    Write-Host ""
    Write-Host "==> Installing packages in: $dir"
    Push-Location $dir
    try {
        npm install
        if ($LASTEXITCODE -ne 0) {
            throw "npm install failed in $dir"
        }
    } finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "All pi extensions installed successfully!"
