#!/bin/bash
#
# Installs emacs from snap, sources or an AppImage
#
# For having access to a recent version of emacs.

dir_path=$(dirname -- "${BASH_SOURCE[0]}")
source "${dir_path}/utils.inc.sh"
set -euo pipefail

TOOLNAME="emacs"

function get_current_emacs_version() {
    if [[ -x "$(command -v emacs)" ]]; then
        emacs --version | head -n1 | cut -d ' ' -f3
    fi
}

function query_install() {
    local -r query_text="$1"
    read -p "${query_text} (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
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

function install_from_sources() {
    local -r github_project="emacs-mirror"
    local -r github_repo="emacs"
    local -r tmpdir=$(mktemp -d)
    local -r current_version=$(get_current_emacs_version)
    local -r bin_dir="${HOME}"/.local/bin
    local -r install_dir="${bin_dir}"/emacs-install

    __log_info "Trying to install from sources"

    # shellcheck disable=SC2064
    trap "trap - RETURN; popd > /dev/null; rm -rf ${tmpdir}" RETURN

    run_cmd echo "Temporary directory: ${tmpdir}"
    pushd "${tmpdir}" > /dev/null

    if ! package=$(utils::download_github_tag_tarball "${github_project}" "${github_repo}" "${tmpdir}" "${current_version}"); then
        __log_error "Failed to download emacs"
        return 1
    elif [[ -z "${package}" ]]; then
        return 0
    fi
    tar -xzf "${package}"

    # Build emacs
    __log_info "Building emacs"
    cd emacs-*/
    if ! run_cmd ./autogen.sh; then
        __log_error "Failed to run autogen for emacs"
        return 1
    fi
    if ! run_cmd ./configure --prefix="${install_dir}" --with-x-toolkit=no --with-xpm=ifavailable --with-jpeg=ifavailable --with-gif=ifavailable --with-tiff=ifavailable --with-gnutls=ifavailable; then
        __log_error "Failed to configure emacs"
        return 1
    fi
    if ! run_cmd make; then
        __log_error "Failed to make emacs"
        return 1
    fi

    __log_info "Install emacs to ${install_dir}"
    rm -rf "${install_dir}"
    if ! run_cmd make install; then
        __log_error "Failed to make install emacs"
        return 1
    fi

    # Copy the built binary to .local/bin
    __log_info "Symlink emacs to ${HOME}/.local/bin"
    mkdir -p "${bin_dir}"
    rm -f "${bin_dir}"/emacs
    ln -s "${install_dir}"/bin/emacs "${bin_dir}"/emacs
}

function install_emacs() {
    __log_info "Installing/updating Emacs"
    __log_info "Emacs version before: $(get_current_emacs_version)"

    install_using_snap && return 0
    install_from_sources && return 0
    query_install "Install using AppImage" && install_using_appimage && return 0
}

install_emacs
