#!/bin/bash

# Installs the following packages:
#   i3
#   i3blocks

set -euo pipefail

function install_i3() {
    local -r i3_packages=(i3
                          i3blocks)

    install_packages "${i3_packages[@]}"
}

install_i3
