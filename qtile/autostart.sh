#! /bin/bash
numlockx &
xrandr --output Virtual-1 --mode 1360x768 &
nitrogen --restore &
dunst -config /home/benny/.config/dunst/dunstrc &
