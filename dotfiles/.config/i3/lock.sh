#!/bin/bash

# i3lock blurred screen inspired by /u/patopop007 and the blog post
# http://plankenau.com/blog/post-10/gaussianlock

# Dependencies:
# imagemagick
# i3lock
# scrot (optional but default)

IMAGE=/tmp/i3lock.png
SCREENSHOT="scrot $IMAGE"

# Get the screenshot, convert it and lock the screen with it
$SCREENSHOT
convert $IMAGE -spread 5 $IMAGE
i3lock -i $IMAGE
rm $IMAGE

# sleep 1 adds a small delay to prevent possible race conditions with suspend
sleep 1
