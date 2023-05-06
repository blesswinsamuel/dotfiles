#!/usr/bin/env python3

# See full documentation here: https://github.com/raycast/script-commands
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Mouse Move
# @raycast.mode fullOutput
#
# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Raycast Scripts

from pynput.mouse import Button, Controller, Listener
import math

import time

mouse = Controller()

# Radius 
# R = 400
R = 100
# measuring screen size
(x,y) = (1920, 1200)
# locating center of the screen 
(X,Y) = (x/2,y/2)
# offsetting by radius 
mouse.position = (X+R,Y)

while True:
    for i in range(360):
        # setting pace with a modulus 
        mouse.position = (X+R*math.cos(math.radians(i)), Y+R*math.sin(math.radians(i)))
        time.sleep(0.01)
# Esc, II to interrupt
