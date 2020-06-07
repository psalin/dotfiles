#!/bin/bash

# Installs or updates kube-ps1, a utility for
# showing k8s context and namespace in the bash prompt

set -euo pipefail

function install_kube_ps1() {
    local -r install_dir="${HOME}"/.kube-ps1

    if [[ ! -d "${install_dir}" ]]; then
        __log_info "Installing kube-ps1"
        run_cmd git clone https://github.com/jonmosco/kube-ps1.git "${install_dir}"
    else
        __log_info "Updating kube-ps1"
        run_cmd git -C "${install_dir}" pull
    fi

    __log_success "kube-ps1 successfully installed"
}

install_kube_ps1
