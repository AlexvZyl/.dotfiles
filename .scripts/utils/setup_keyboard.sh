#!/bin/sh

setxkbmap -option caps:escape
xmodmap -e 'keycode 112 = NoSymbol'
xmodmap -e 'keycode 117 = NoSymbol'

xset r rate 165 50
