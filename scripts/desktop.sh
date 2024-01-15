#!/bin/bash

# Installs the following packages:
# i3wm packages
#   i3
#   i3blocks
# custom i3 locking
#   imagemagick
#   scrot
# screen setup tools
#   arandr
#   autorandr
# sound control
#   pavucontrol
# backlight control
#   light

set -euo pipefail

function install_desktop() {
    local -r desktop_packages=(i3
                               i3blocks
                               arandr
                               autorandr
                               imagemagick
                               scrot
                               pavucontrol
                               light)

    install_packages "${desktop_packages[@]}"
}

install_desktop
