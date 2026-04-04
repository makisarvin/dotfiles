#!/usr/bin/env bash

mode=${1:-search}
options=${2}
dir="$HOME/.config/rofi"

style=$(cat ${dir}/.current_style)
config=${style}/${mode}

### Run
if [ "${options,,}" == "dmenu" ]; then
  rofi -dmenu -p "󰅍" -theme ${dir}/styles/${config}.rasi
else
  rofi -show drun -theme ${dir}/styles/${config}.rasi
fi
