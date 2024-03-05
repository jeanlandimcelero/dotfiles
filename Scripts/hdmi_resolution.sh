#!/bin/sh
cvt 2560 1080 30
xrandr --newmode  "2560x1080_30.00"  106.75  2560 2640 2896 3232  1080 1083 1093 1102 -hsync +vsync
xrandr --addmode HDMI-1 "2560x1080_30.00"
xrandr --output HDMI-1 --mode "2560x1080_30.00"

notify-send "The HDMI Widescreen monitor has been changed."
