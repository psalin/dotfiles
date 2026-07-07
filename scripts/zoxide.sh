#!/bin/bash
#
# Installs zoxide from github
#
# For having access to a recent version of zoxide

dir_path=$(dirname -- "${BASH_SOURCE[0]}")
source "${dir_path}/utils.inc.sh"
set -euo pipefail

function get_current_zoxide_version() {
    if [[ -x "$(command -v zoxide)" ]]; then
        zoxide -V | cut -d ' ' -f2
    fi
}

function install_from_github() {
    local -r tmpdir=$(mktemp -d)
    local -r bin_dir="${HOME}"/.local/bin

    # shellcheck disable=SC2064
    trap "trap - RETURN; popd > /dev/null; rm -rf ${tmpdir}" RETURN

    run_cmd echo "Temporary directory: $tmpdir"
    pushd "${tmpdir}" > /dev/null

    if ! package=$(utils::download_github_release ajeetdsouza zoxide x86_64-unknown-linux . "$(get_current_zoxide_version)"); then
        __log_error "Failed to download tmux"
        return 1
    elif [[ -z "${package}" ]]; then
        return 0
    fi

    tar -xzf "${package}"

    __log_info "Copy zoxide to ${HOME}/.local/bin"
    cp -f ./zoxide "${bin_dir}"/zoxide
}

function install_zoxide() {
    __log_info "Installing/updating zoxide"
    __log_info "Zoxide version before: $(get_current_zoxide_version)"

    install_from_github && return 0
}

install_zoxide
