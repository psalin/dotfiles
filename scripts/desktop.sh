#!/bin/bash

# Installs the following packages:
# regolith packages
#   regolith-desktop regolith-session-sway regolith-sway-gaps
# sound control
#   pavucontrol
# backlight control
#   light

set -euo pipefail

function install_desktop() {
    local -r desktop_packages=(regolith-desktop
			       regolith-session-sway
			       regolith-sway-gaps
                               pavucontrol
                               light)

    install_packages "${desktop_packages[@]}"
}

install_desktop
