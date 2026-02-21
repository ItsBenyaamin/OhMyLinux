#!/bin/bash

DIR=~/Pictures/Screenshots
if [ ! -d "$DIR" ]; then
    mkdir $DIR
fi

file=`date +'%Y%m%d_%H%M.png'`

grim -g "$(slurp)" "$DIR/$file" \
    && copyq copy image/png "$DIR/$file" \
    && hyprctl notify 5 2500 0 "Screenshot: $file"
