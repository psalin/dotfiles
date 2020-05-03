#!/bin/bash

# Installs the following base packages:
#   bash-completion
#   curl
#   global

set -euo pipefail

function install_basepackages() {
    local -r base_packages=(bash-completion
                       curl
                       global)

    install_packages "${base_packages[@]}"
}

install_basepackages
