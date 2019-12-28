#!/bin/bash

# Checks emacs of at least a certain version is installed and installs it if needed

set -euo pipefail

: "${minimum_version:=25.1}"

function _confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

function _is_version_less_than() {
    [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

function _get_current_emacs_version() {
    emacs --version | head -n1 | cut -d ' ' -f3
}

function _check_emacs_version() {
    if [ ! -x "$(command -v emacs)" ]; then
        __log_info "Emacs ${minimum_version} or newer is not installed"
        return 1
    fi

    if _is_version_less_than "$(_get_current_emacs_version)" "${minimum_version}"; then
        __log_info "The installed version is too old: $(_get_current_emacs_version) < ${minimum_version}"
        return 1
    fi

    __log_success "The installed version is recent enough: $(_get_current_emacs_version) >= ${minimum_version}"
    return 0
}

function _has_sudo_rights() {
    sudo -v
}

function _apt_repo_has_new_enough_version() {
    local pkgname pkgver
    pkgname=$(apt-cache show emacs | grep Depends | cut -d ' ' -f2)
    pkgver=$(apt-cache policy "${pkgname}" | grep 'Candidate:' | cut -d ' ' -f4 | cut -d: -f2- | awk -F '[-+]' '{print $1}')
    _is_version_less_than "${minimum_version}" "${pkgver}"
}

function _make_emacs_command_reference_newest_bin() {
    # If there are multiple emacses and the most recent one is not default, then symlink it from ${HOME}/bin
    if ! _check_emacs_version; then
        if [ "$(update-alternatives --list emacs | wc -l)" -gt 1 ]; then
            newest_bin=$(update-alternatives --list emacs | sort -r | head -n1)
            _add_symlink_to_local_bin "${newest_bin}"
        fi
    fi
}

function _add_symlink_to_local_bin() {
    local target=$1
    if mkdir -p "${HOME}"/bin && rm -f "${HOME}"/bin/emacs && ln -s "${target}" "${HOME}"/bin/emacs; then
        __log_info "Added symlink to newest emacs (${target}) to ${HOME}/bin"
    else
        __log_warning "Failed to make symbolic link to the newest emacs"
    fi
 }

function _install_using_apt() {
    # Install from distribution repo if possible
    if _apt_repo_has_new_enough_version; then
        __log_info "Trying to install from distribution repository"
        if sudo apt-get install -y emacs; then
            _make_emacs_command_reference_newest_bin
            __log_success "Emacs $(_get_current_emacs_version) successfully installed"
            return 0
        fi
        __log_warning "Failed to install from distribution repository"
    fi

    # Otherwise try installing the latest version from ppa:kelleyk/emacs
    __log_info "Trying to install latest version from ppa:kelleyk/emacs"
    if ! apt-cache policy | grep kelleyk/emacs; then
        if [ ! -x "$(command -v add-apt-repository)" ]; then
            sudo apt update && sudo apt-get install -y software-properties-common
        fi

        if ! sudo add-apt-repository -u ppa:kelleyk/emacs; then
            __log_warning "Failed to add ppa:kelleyk/emacs"
            return 1
        fi
    fi

    if [ -x "$(command -v emacs)" ]; then
        _confirm "Do you want to remove all other emacses before installing? [y/N]" && sudo apt-get remove -y emacs*
    fi

    if sudo apt-get install -y emacs26; then
        _make_emacs_command_reference_newest_bin
        __log_success "Emacs $(_get_current_emacs_version) successfully installed"
    fi
}

function _install_using_conda() {
    __log_info "Trying to install using conda"
    local install_script="${HOME}"/miniconda.sh
    local install_dir="${HOME}"/miniconda

    if [ ! -d "${HOME}/miniconda" ]; then
        # Download Miniconda
        if ! curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > "${install_script}"; then
            __log_error "Failed to download Miniconda"
            return 1
        fi

        # Install Miniconda
        if ! (bash "${install_script}" -b -p "${install_dir}" && rm -f "${install_script}"); then
            __log_error "Failed to install Miniconda"
            return 1
        fi
    fi

    # Install Emacs using Miniconda
    if ! "${install_dir}"/bin/conda install -c conda-forge emacs -y; then
        __log_error "Failed to install emacs using conda"
        return 1
    fi

    # Add symlink
    if ! _add_symlink_to_local_bin "${install_dir}"/bin/emacs; then
        __log_error "Failed to copy emacs binaries to local bin"
        return 1
    fi

    __log_success "Emacs $(_get_current_emacs_version) successfully installed"
}

function install_emacs() {
    _check_emacs_version && return 0

    _has_sudo_rights && _install_using_apt && return 0

    _install_using_conda && return 0
}

__log_info "Installing Emacs"
install_emacs
