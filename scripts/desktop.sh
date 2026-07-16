#!/bin/bash

# Sets up the Regolith apt repository and installs the following packages:
# regolith packages
#   regolith-desktop regolith-session-sway regolith-sway-gaps
# terminal emulator
#   foot
# sound control
#   pavucontrol
# backlight control
#   light
#
# Also removes regolith-wm-navigation, which the dotfiles override.

set -euo pipefail

function setup_regolith_repo() {
    local -r keyring_file="/usr/share/keyrings/regolith-archive-keyring.gpg"
    local -r sources_file="/etc/apt/sources.list.d/regolith.list"
    local -r regolith_version="v3.4"
    local ubuntu_version repo_line
    ubuntu_version=$(lsb_release -cs)
    repo_line="deb [arch=amd64 signed-by=${keyring_file}] https://archive.regolith-desktop.com/ubuntu/stable ${ubuntu_version} ${regolith_version}"

    if [[ -f "${sources_file}" ]]; then
        __log_info "Regolith apt repository already configured"
        return 0
    fi

    __log_info "Setting up the Regolith apt repository"
    if ! run_cmd bash -c "set -o pipefail; curl -fsSL https://archive.regolith-desktop.com/regolith.key | \
            gpg --dearmor | sudo tee ${keyring_file} > /dev/null"; then
        __log_error "Failed to install the Regolith archive key"
        return 1
    fi
    if ! run_cmd sudo bash -c "echo '${repo_line}' > ${sources_file}"; then
        __log_error "Failed to add the Regolith apt repository"
        return 1
    fi
    __log_success "Regolith apt repository configured"
}

function remove_navigation_package() {
    # Remove the navigation package, the dotfiles override it
    local -r package="regolith-wm-navigation"

    if ! check_package "${package}"; then
        __log_info "${package}: Already removed"
        return 0
    fi

    if ! run_cmd sudo apt-get remove -y "${package}"; then
        __log_error "Failed to remove ${package}"
        return 1
    fi
    __log_success "${package} removed"
}

function install_desktop() {
    local -r desktop_packages=(regolith-desktop
                               regolith-session-sway
                               regolith-sway-gaps
                               foot
                               pavucontrol
                               light)

    install_packages "${desktop_packages[@]}"
    remove_navigation_package
}

setup_regolith_repo && install_desktop
