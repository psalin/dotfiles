#!/bin/bash
#
# Installs emacs of at least a certain version if not yet installed

set -euo pipefail

: "${MIN_VERSION:=26}"
readonly MIN_VERSION

function _confirm() {
    local response

    read -r -p "${1:-Are you sure? [y/N]} " response
    case "${response}" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

function _is_version_less_than() {
    [[ "$1" == "$(echo -e "$1\n$2" | sort -V | head -n1)" ]]
}

function _get_current_emacs_version() {
    emacs --version | head -n1 | cut -d ' ' -f3
}

function _check_emacs_version() {
    if [[ ! -x "$(command -v emacs)" ]]; then
        __log_info "Emacs ${MIN_VERSION} or newer is not installed"
        return 1
    fi

    if _is_version_less_than "$(_get_current_emacs_version)" "${MIN_VERSION}"; then
        __log_info "The installed version is too old:"\
                   "$(_get_current_emacs_version) < ${MIN_VERSION}"
        return 1
    fi

    __log_success "The installed version is recent enough:"\
                  "$(_get_current_emacs_version) >= ${MIN_VERSION}"
    return 0
}

function _has_sudo_rights() {
    run_cmd sudo -v
}

function _apt_repo_has_new_enough_version() {
    local pkgname="$1"
    local pkgver

    run_cmd sudo apt update

    # If metapackage, detect real package
    if [[ "${pkgname}" == "emacs" ]]; then
        pkgname="$(apt-cache show emacs | grep Depends | cut -d ' ' -f2)"
    fi
    pkgver="$(apt-cache policy "${pkgname}" \
                 | grep 'Candidate:' \
                 | cut -d ' ' -f4 \
                 | cut -d: -f2- \
                 | awk -F '[-+]' '{print $1}')"

    if [[ ! -x "$(command -v emacs)" ]]; then
        if _is_version_less_than "${pkgver}" "${MIN_VERSION}"; then
            __log_info "APT version is not newer than the minimum required version: ${pkgver}"
            return 1
        fi
        return 0
    fi

    if _is_version_less_than "${pkgver}" "$(_get_current_emacs_version)"; then
        __log_info "APT version is not newer than the current version: ${pkgver}"
        return 1
    fi

    __log_info "Found newer version: ${pkgver}"
}

function _make_emacs_command_reference_newest_bin() {
    # When multiple versions and the most recent one is not default, symlink it from ${HOME}/bin
    if ! _check_emacs_version; then
        if [[ "$(update-alternatives --list emacs | wc -l)" -gt 1 ]]; then
            newest_bin="$(update-alternatives --list emacs | sort -r | head -n1)"
            _add_symlink_to_local_bin "${newest_bin}"
        fi
    fi
}

function _add_symlink_to_local_bin() {
    local target="$1"

    if run_cmd mkdir -p "${HOME}"/bin \
            && run_cmd rm -f "${HOME}"/bin/emacs \
            && run_cmd ln -s "${target}" "${HOME}"/bin/emacs; then

        __log_info "Added symlink to newest emacs (${target}) to ${HOME}/bin"
    else
        __log_warning "Failed to make symbolic link to the newest emacs"
    fi
 }

function _install_using_apt() {
    # Install from distribution repo if possible
    if _apt_repo_has_new_enough_version "emacs"; then
        __log_info "Trying to install/update from distribution repository"

        if run_cmd sudo apt-get install -y emacs; then
            _make_emacs_command_reference_newest_bin
            __log_success "Emacs $(_get_current_emacs_version) successfully installed"
            return 0
        fi
        __log_warning "Failed to install from distribution repository"
    fi

    # Otherwise try installing the latest version from ppa:kelleyk/emacs
    if ! apt-cache policy | run_cmd grep kelleyk/emacs; then
        if [[ ! -x "$(command -v add-apt-repository)" ]]; then
            run_cmd sudo apt update && run_cmd sudo apt-get install -y software-properties-common
        fi

        if ! run_cmd sudo add-apt-repository -y -u ppa:kelleyk/emacs; then
            __log_warning "Failed to add ppa:kelleyk/emacs"
            return 1
        fi
    fi

    local -r pkelley_version=emacs27
    if _apt_repo_has_new_enough_version "${pkelley_version}"; then
        __log_info "Trying to install/update latest version from ppa:kelleyk/emacs"

        if [[ -x "$(command -v emacs)" ]]; then
            _confirm "Do you want to remove all other APT emacses before installing? [y/N]" \
                && run_cmd sudo apt-get remove -y emacs*
            sudo apt-get remove -y emacs*
        fi

        if run_cmd sudo apt-get install -y "${pkelley_version}"; then
            _make_emacs_command_reference_newest_bin
            __log_success "Emacs $(_get_current_emacs_version) successfully installed"
        fi
    fi
}

function _install_using_conda() {
    local -r install_script="${HOME}"/miniconda.sh
    local -r install_dir="${HOME}"/miniconda
    local -r miniconda_uri="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"

    __log_info "Trying to install using conda"

    if [[ ! -d "${HOME}/miniconda" ]]; then
        # Download Miniconda
        if ! curl -s "${miniconda_uri}" > "${install_script}"; then
            __log_error "Failed to download Miniconda"
            return 1
        fi

        # Install Miniconda
        if ! (run_cmd bash "${install_script}" -b -p "${install_dir}" \
                  && run_cmd rm -f "${install_script}"); then
            __log_error "Failed to install Miniconda"
            return 1
        fi
    fi

    # Install Emacs using Miniconda
    if ! run_cmd "${install_dir}"/bin/conda install -c conda-forge emacs -y; then
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
    __log_info "Installing/updating Emacs"
    __log_info "Current Emacs version: $(_get_current_emacs_version)"

    _has_sudo_rights && _install_using_apt && return 0
    _check_emacs_version && return 0

    _install_using_conda && return 0
}

install_emacs
