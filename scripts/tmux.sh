#!/bin/bash
#
# Installs tmux from snap, sources or an AppImage
#
# For having access to a recent version of tmux

dir_path=$(dirname -- "${BASH_SOURCE[0]}")
source "${dir_path}/utils.inc.sh"
set -euo pipefail

TOOLNAME="tmux"

function get_current_tmux_version() {
    if [[ -x "$(command -v tmux)" ]]; then
        tmux -V | head -n1 | cut -d ' ' -f2
    fi
}

function query_install() {
    local -r query_text="$1"
    read -p "${query_text} (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

function install_using_snap() {
    local -r current_version=$(get_current_tmux_version)
    utils::install_using_snap "${TOOLNAME}" "${current_version}" "true"
    return $?
}

function install_using_appimage() {
    local -r github_project="kiyoon"
    local -r github_repo="tmux-appimage"
    local -r package_type="tmux-appimage"
    local -r output_dir="${HOME}/.local/bin"
    local -r current_version=$(get_current_tmux_version)
    utils::install_github_appimage "${TOOLNAME}" "${github_project}" "${github_repo}" "${package_type}" "${output_dir}" "${current_version}"
    return $?
}

function install_from_sources() {
    local -r ncurses_version="6.5"

    __log_info "Trying to install tmux from sources"
    tmpdir=$(mktemp -d)
    run_cmd echo "Temporary directory: ${tmpdir}"
    pushd "${tmpdir}" > /dev/null
    local -r build_dir="${tmpdir}/build_dir"

    # shellcheck disable=SC2064
    trap "trap - RETURN; popd > /dev/null; rm -rf ${tmpdir}" RETURN

    # Download and extract the needed sources
    __log_info "Downloading tmux"
    if ! package=$(utils::download_github_release tmux tmux tmux . "$(get_current_tmux_version)"); then
        __log_error "Failed to download tmux"
        return 1
    elif [[ -z "${package}" ]]; then
        return 0
    fi
    __log_info "Downloading libevent"
    if ! package=$(utils::download_github_release libevent libevent stable .); then
        __log_error "Failed to download libevent"
        return 1
    fi
    __log_info "Downloading ncurses"
    if ! run_cmd curl -O https://ftp.gnu.org/gnu/ncurses/ncurses-"${ncurses_version}".tar.gz && \
	    ! run_cmd curl -O https://mirrors.dotsrc.org/gnu/ncurses/ncurses-"${ncurses_version}".tar.gz; then
	__log_error "Failed to download ncurses"
	return 1
    fi
    for f in *.tar.gz; do tar -xzf "$f"; done

    # Setup libevent
    __log_info "Building libevent"
    cd libevent-*-stable
    if ! run_cmd ./configure --prefix="${build_dir}" --disable-shared; then
        __log_error "Failed to configure libevent"
        return 1
    fi
    if ! run_cmd make; then
        __log_error "Failed to make libevent"
        return 1
    fi
    if ! run_cmd make install; then
        __log_error "Failed to make install libevent"
        return 1
    fi
    cd ..

    # Setup ncurses
    __log_info "Building ncurses"
    cd ncurses-"${ncurses_version}"
    if ! run_cmd ./configure --prefix="${build_dir}"; then
        __log_error "Failed to configure ncurses"
        return 1
    fi
    if ! run_cmd make; then
        __log_error "Failed to make ncurses"
        return 1
    fi
    if ! run_cmd make install; then
        __log_error "Failed to make install ncurses"
        return 1
    fi
    cd ..

    # Build tmux
    __log_info "Building tmux"
    cd tmux-*/
    if ! run_cmd ./configure CFLAGS="-I${build_dir}/include -I${build_dir}/include/ncurses" LDFLAGS="-L${build_dir}/lib -L${build_dir}/include/ncurses -L${build_dir}/include"; then
        __log_error "Failed to configure tmux"
        return 1
    fi
    export CPPFLAGS="-I${build_dir}/include -I${build_dir}/include/ncurses"
    export LDFLAGS="-static -L${build_dir}/include -L${build_dir}/include/ncurses -L${build_dir}/lib"
    if ! run_cmd make; then
        __log_error "Failed to make tmux"
        return 1
    fi

    # Copy the built binary to .local/bin
    __log_info "Copying tmux to ${HOME}/.local/bin"
    mkdir -p "${HOME}"/.local/bin
    if [ -f "${HOME}"/.local/bin/tmux ]; then
        cp -f "${HOME}"/.local/bin/tmux "${HOME}"/.local/bin/tmux.old
    fi
    cp -f tmux "${HOME}"/.local/bin/tmux
    cd ..
}

function install_tmux_tpm() {
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"

    if [ -d "$tpm_dir" ]; then
        # Update existing installation
        if git -C "$tpm_dir" pull; then
            __log_success "tmux tpm updated, please reload tmux."
	    return 0
        else
            __log_error "Failed to update tmux tpm."
	    return 1
        fi
    else
        # Fresh install
        if git clone https://github.com/tmux-plugins/tpm "$tpm_dir"; then
            __log_success "tmux tpm installed, please reload tmux."
	    return 0
        else
            __log_error "Failed to install tmux tpm."
	    return 1
        fi
    fi
}

function install_tmux() {
    __log_info "Installing/updating tmux"

    install_using_snap && return 0
    install_from_sources && return 0
    query_install "Install using AppImage" && install_using_appimage && return 0
}

install_tmux && install_tmux_tpm



