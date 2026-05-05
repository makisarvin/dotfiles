#!/bin/bash

OUTPUT_DIR="$HOME/.config/aether/theme/backgrounds"

# start aether
/usr/bin/aether

# Get the wallpaper
FILE=$(find "$OUTPUT_DIR" -type f | head -n 1)

# wallpaper
hyprctl hyprpaper wallpaper ", $FILE, fill"
