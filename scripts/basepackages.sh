#!/bin/bash

# Installs the following base packages:
#   bash-completion
#   curl
#   global

set -euo pipefail

function install_basepackages() {
    local packages=(bash-completion
                    curl
                    global)

    install_packages "${packages[@]}"
}

install_basepackages
