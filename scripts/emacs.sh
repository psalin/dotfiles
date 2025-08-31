#!/bin/bash
#
# Installs emacs from snap or an AppImage
#
# For having access to a recent version of emacs. AppImage
# is generally needed when sudo access is not available.
# AppImage is only used when snap installation is not possible.

dir_path=$(dirname -- "${BASH_SOURCE[0]}")
source "${dir_path}/utils.inc.sh"
set -euo pipefail

TOOLNAME="emacs"

function get_current_emacs_version() {
    if [[ -x "$(command -v emacs)" ]]; then
        emacs --version | head -n1 | cut -d ' ' -f3
    fi
}

function install_using_snap() {
    local -r current_version=$(get_current_emacs_version)
    utils::install_using_snap "${TOOLNAME}" "${current_version}" "true"
    return $?
}

function install_using_appimage() {
    local -r github_project="blahgeek"
    local -r github_repo="emacs-appimage"
    local -r package_type="nox-x86_64"
    local -r output_dir="${HOME}/.local/bin"
    local -r current_version=$(get_current_emacs_version)
    utils::install_github_appimage "${TOOLNAME}" "${github_project}" "${github_repo}" "${package_type}" "${output_dir}" "${current_version}"
    return $?
}

function install_emacs() {
    __log_info "Installing/updating Emacs"
    __log_info "Emacs version before: $(get_current_emacs_version)"

    install_using_snap && return 0
    install_using_appimage && return 0

    __log_info "Emacs version after: $(get_current_emacs_version)"
}

install_emacs
