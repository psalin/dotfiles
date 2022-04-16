#!/bin/bash

# Installs the following base packages:
#   bash-completion
#   curl
#   global
#   jq

set -euo pipefail

function install_basepackages() {
    local -r base_packages=(bash-completion
                       curl
                       global
                       jq)

    install_packages "${base_packages[@]}"
}

install_basepackages
