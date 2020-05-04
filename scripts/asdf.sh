#!/bin/bash

# Installs or updates asdf

set -euo pipefail

function install_asdf() {
    local -r install_dir="${HOME}"/.asdf

    if [[ ! -d "${install_dir}" ]]; then
        __log_info "Installing asdf"
        run_cmd git clone https://github.com/asdf-vm/asdf.git "${install_dir}" --branch v0.7.8
    elif [[ -x "$(command -v fzf)" ]]; then
         __log_info "Updating asdf"
         run_cmd asdf update
    else
        __log_error "${install_dir} exists, but asdf command not found"
    fi

    __log_success "asdf successfully installed"
}

install_asdf
