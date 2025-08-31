#!/bin/bash
#
# Installs or updates asdf

dir_path=$(dirname -- "${BASH_SOURCE[0]}")
source "${dir_path}/utils.inc.sh"
set -euo pipefail

function usage() {
    echo "$(basename "${BASH_SOURCE[0]}") [install]                          Installs asdf"
    echo "$(basename "${BASH_SOURCE[0]}") install-tool <name> [<version>]    Installs a specific or the latest version of a tool"
}

function get_current_asdf_version() {
    if [[ -x "$(command -v asdf)" ]]; then
        asdf version | head -n1 | cut -d ' ' -f1
    fi
}

function install_asdf() {
    local -r github_project="asdf-vm"
    local -r github_repo="asdf"
    local package_type
    local os_type
    local arch
    local -r output_dir="${HOME}/.local/bin"
    local -r current_version=$(get_current_asdf_version)
    local package

    # Detect OS and architecture for selecting the correct package
    os_type=$(uname | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)
    if [[ "${arch}" == "x86_64" ]]; then
        arch="amd64"
    elif [[ "${arch}" == "aarch64" || "${arch}" == "arm64" ]]; then
        arch="arm64"
    fi
    package_type="${os_type}-${arch}"

    if ! package=$(utils::download_github_release "${github_project}" "${github_repo}" "${package_type}" "${output_dir}" "${current_version}"); then
        __log_error "Failed to download asdf from ${github_project}/${github_repo}"
        return 1
    elif [[ -z "${package}" ]]; then
        return 0
    fi
    if ! tar xvfz "${package}" -C "${output_dir}"; then
        rm -f "${package}"
        __log_error "Failed to install ${package}"
        return 1
    fi
    rm -f "${package}"
    return 0
}

function install_tool() {
    local name=$1
    local version=${2:-latest}

    asdf plugin add "${name}"
    asdf install "${name}" "${version}"
    asdf set -u "${name}" "${version}"
}

if [ $# -eq 0 ] || { [ $# -eq 1 ] && [ "$1" = "install" ]; }; then
    install_asdf
elif { [ $# -eq 2 ] || [ $# -eq 3 ]; } && [ "$1" = "install-tool" ]; then
    install_tool "$2" "${3:-latest}"
else
    usage
fi
