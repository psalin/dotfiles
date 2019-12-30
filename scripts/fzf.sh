#!/bin/bash

# Installs or updates fzf

set -euo pipefail

function install_fzf() {
    local install_dir="${HOME}"/.fzf

    if [ ! -d "${install_dir}" ]; then
        __log_info "Installing fzf"
        git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}"/.fzf
    else
        __log_info "Updating fzf"
        git -C "${install_dir}" pull
    fi

    "${HOME}"/.fzf/install --no-update-rc --completion --key-bindings

    __log_success "fzf successfully installed"
}

install_fzf
