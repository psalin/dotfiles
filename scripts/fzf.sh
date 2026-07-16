#!/bin/bash
#
# Installs fzf from github
#
# For having access to a recent version of fzf

dir_path=$(dirname -- "${BASH_SOURCE[0]}")
source "${dir_path}/utils.inc.sh"
set -euo pipefail

function get_current_fzf_version() {
    if [[ -x "$(command -v fzf)" ]]; then
        fzf --version | cut -d ' ' -f1
    fi
}

function install_from_github() {
    local -r tmpdir=$(mktemp -d)
    local -r bin_dir="${HOME}"/.local/bin

    # shellcheck disable=SC2064
    trap "trap - RETURN; popd > /dev/null; rm -rf ${tmpdir}" RETURN

    run_cmd echo "Temporary directory: $tmpdir"
    pushd "${tmpdir}" > /dev/null

    if ! package=$(utils::download_github_release junegunn fzf linux_amd64.tar.gz . "$(get_current_fzf_version)"); then
        __log_error "Failed to download fzf"
        return 1
    elif [[ -z "${package}" ]]; then
        return 0
    fi

    tar -xzf "${package}"

    __log_info "Copy fzf to ${HOME}/.local/bin"
    mkdir -p "${bin_dir}"
    cp -f ./fzf "${bin_dir}"/fzf
}

function install_fzf() {
    __log_info "Installing/updating fzf"
    __log_info "Fzf version before: $(get_current_fzf_version)"

    install_from_github && return 0
}

install_fzf
