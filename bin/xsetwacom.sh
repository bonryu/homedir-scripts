#!/bin/bash
ids=$(xsetwacom list | grep 'type: PAD' | cut -f2 | cut -d' ' -f2)
id=${ids[0]}
xsetwacom set "$id" Button 1 "key ctrl alt shift m"
xsetwacom set "$id" Button 9 "button 4"
xsetwacom set "$id" Button 8 "button 5"

