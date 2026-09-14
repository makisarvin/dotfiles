#!/usr/bin/env bash
# Setup script for pi-dev profiles
# Installs npm dependencies in all .pi/npm directories

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing pi extensions..."

# Find all package.json files inside .pi/npm directories
mapfile -t npm_dirs < <(find "$SCRIPT_DIR" -type f -path '*/.pi/npm/package.json' | sort)

if [ ${#npm_dirs[@]} -eq 0 ]; then
    echo "No .pi/npm directories found."
    exit 0
fi

for pkg_json in "${npm_dirs[@]}"; do
    dir="$(dirname "$pkg_json")"
    echo ""
    echo "==> Installing packages in: $dir"
    (
        cd "$dir"
        npm install
    )
done

echo ""
echo "All pi extensions installed successfully!"
