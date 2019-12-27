#!/bin/bash

# Installs the following base packages:
#   bash-completion
#   curl
#   global

set -euo pipefail

function install_basepackages() {
    local packages_not_installed=()
    local packages=(bash-completion
                    curl
                    global)

    for package in "${packages[@]}"; do
        if ! check_package "${package}"; then
            __log_info "${package}: Not installed"
            packages_not_installed+=("${package}")
        fi
    done

    if [ ${#packages_not_installed[@]} -ne 0 ]; then
        if ! sudo -v; then
            __log_warning "Could not install base packages, no sudo rights"
            return 1
        fi
    else
        __log_success "All base packages are already installed"
        return 0
    fi

    __log_info "Installing packages ${packages_not_installed[*]}"
    if ! sudo apt-get install -y "${packages_not_installed[@]}"; then
        for package in "${packages[@]}"; do
            if ! check_package "${package}"; then
                __log_error "${package}: not installed"
            fi
        done
        return 1
    fi

    __log_success "Base packages successfully installed"
}

install_basepackages
