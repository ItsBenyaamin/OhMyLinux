#!/usr/bin/env bash

# USAGE: ./toggletrackpad.sh enable/disable

TOUCHPAD=$(hyprctl devices | grep -i touchpad | awk '{print $1}')

if [ -z "$TOUCHPAD" ]; then
    echo "Touchpad not found!"
    exit 1
fi

if [ "$1" == "disable" ]; then
    hyprctl keyword "device[$TOUCHPAD]:enabled" false
elif [ "$1" == "enable" ]; then
    hyprctl keyword "device[$TOUCHPAD]:enabled" true
fi
