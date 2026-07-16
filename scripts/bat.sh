#!/bin/bash
#
# Installs bat from github
#
# For having access to a recent version of bat

dir_path=$(dirname -- "${BASH_SOURCE[0]}")
source "${dir_path}/utils.inc.sh"
set -euo pipefail

function get_current_bat_version() {
    if [[ -x "$(command -v bat)" ]]; then
        bat --version | cut -d ' ' -f2
    fi
}

function install_from_github() {
    local -r tmpdir=$(mktemp -d)
    local -r bin_dir="${HOME}"/.local/bin

    # shellcheck disable=SC2064
    trap "trap - RETURN; popd > /dev/null; rm -rf ${tmpdir}" RETURN

    run_cmd echo "Temporary directory: $tmpdir"
    pushd "${tmpdir}" > /dev/null

    if ! package=$(utils::download_github_release sharkdp bat x86_64-unknown-linux-gnu.tar.gz . "$(get_current_bat_version)"); then
        __log_error "Failed to download bat"
        return 1
    elif [[ -z "${package}" ]]; then
        return 0
    fi

    tar -xzf "${package}"

    __log_info "Copy bat to ${HOME}/.local/bin"
    mkdir -p "${bin_dir}"
    cp -f ./bat-*/bat "${bin_dir}"/bat
}

function install_bat() {
    __log_info "Installing/updating bat"
    __log_info "Bat version before: $(get_current_bat_version)"

    install_from_github && return 0
}

install_bat
