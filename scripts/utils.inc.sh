#!/bin/bash
#
# Contains various utility functions that can be used from scripts

set -euo pipefail

#######################################
# Compares two versions
# Arguments:
#   First version
#   Second version
# Returns:
#   0 if the first version is newer than the second, otherwise 1
function utils::is_version_newer_than() {
    [[ "$1" != "$(echo -e "$1\n$2" | sort -V | head -n1)" ]]
}

#######################################
# Attempts to install newer tools using snap
#   Installation is only done if the snap version is newer than the current version
# Arguments:
#   Tool to install
#   Current version of the tool, or empty if not installed
#   Whether --classic should be used, true or false
# Returns:
#   0 if installation was successful or already up-to-date, otherwise 1
function utils::install_using_snap() {
    local -r toolname="$1"
    local -r current_version="${2:-}"
    local -r use_classic="${3:-false}"
    local install_opts=""
    
    __log_info "Trying to install ${toolname} using snap"
    
    if [[ -x "$(command -v snap)" ]]; then
        snap_version=$(snap info "${toolname}" | awk '/^  latest\/stable:/ {print $2}')
        if ! utils::is_version_newer_than "${snap_version}" "${current_version}"; then
            __log_info "Version found: ${snap_version}. The current version ${current_version} of ${toolname} is already up-to-date."
            return 0
        else
            __log_info "Version found: ${snap_version}. Updating the current version ${current_version} of ${toolname}."
        fi

        if [ "${use_classic}" = "true" ]; then
            install_opts+="--classic"
        fi
        if ! run_cmd snap install ${install_opts} "${toolname}"; then
            __log_error "Failed to install ${toolname} using snap"
            return 1
        fi

        if ! run_cmd ln -sf "/snap/bin/${toolname}" "${HOME}/.local/bin/${toolname}"; then
            __log_error "Failed to create a symbolic link named ${toolname} to /snap/bin/${toolname}"
            return 1
        fi
    else
        __log_warning "Couldn't install ${toolname} using snap, snap not available"
        return 1
    fi
    return 0
}

#######################################
# Downloads a github release
#   The download is only done if the version is newer than the current version
# Arguments:
#   Github project
#   Github repo
#   Package string, partial string to identify which package to download in case several exist
#   Output dir, absolute path
#   Current version of the tool, or empty if not installed
# Outputs:
#   The full path of the downloaded package if successful
# Returns:
#   0 if the download was successful or already up-to-date, otherwise 1
function utils::download_github_release() {
    local -r github_project="$1"
    local -r github_repo="$2"
    local -r package_type="$3"
    local -r output_dir="$4"
    local -r current_version="${5:-}"
    local latest_release_url
    local latest_tag
    local latest_version
    local release_page
    local asset_url
    local full_asset_url

    # Get the latest release tag. Could be gotten directly from api.github.com but can return 403 due to rate limits.
    if ! latest_release_url=$(curl --fail -s -L -o /dev/null -w "%{url_effective}" https://github.com/"${github_project}"/"${github_repo}"/releases/latest); then
        __log_error "Failed to get latest release tag from ${github_project}/${github_repo}"
        return 1
    fi
    latest_tag=${latest_release_url##*/}

    # If the tag is not a version string, try to get the version from the html
    if [[ ! "${latest_tag}" =~ ^v?[0-9] ]]; then
        __log_info "The latest tag ${latest_tag} is not a version, trying to get version from page header"
        release_page=$(curl -s "${latest_release_url}")
        latest_version=$(echo "${release_page}" | grep -oP '<h1 data-view[^>]*>\K.*?(?=</h1>)' | head -n 1 | cut -d ' ' -f2)
    else
        latest_version="${latest_tag}"
    fi

    if ! utils::is_version_newer_than "${latest_version}" "${current_version}"; then
        __log_info "Version found: ${latest_version}. The current version ${current_version} of ${github_project}/${github_repo} is already up-to-date."
        return 0
    else
        __log_info "Version found: ${latest_version}. Updating the current version ${current_version} of ${github_project}/${github_repo}."
    fi

    # Fetch release page HTML
    release_page=$(curl -s https://github.com/"${github_project}"/"${github_repo}"/releases/expanded_assets/"${latest_tag}")

    # Try to find matching asset
    asset_url=$(echo "${release_page}" | grep -oP 'href="\K[^"]+' | grep "${package_type}" | head -n 1)

    if [ -z "${asset_url}" ]; then
        __log_error "No suitable asset found for PACKAGE=${package_type}"
        return 1
    fi

    # Download the asset and extract the binary to .local/bin
    full_asset_url="https://github.com${asset_url}"
    __log_info "Downloading asset: ${full_asset_url}"

    pushd "${output_dir}" > /dev/null
    if ! run_cmd curl -L -O "${full_asset_url}"; then
        __log_error "Failed to download ${full_asset_url}"
        popd > /dev/null
        return 1
    fi
    echo "$(pwd)/$(basename "${full_asset_url}")"
    popd > /dev/null
    return 0
}

#######################################
# Attempts to install a newer tool version using a github appimage
#   Installation is only done if the version is newer than the current version
# Arguments:
#   Name of the tool to install, used to symlink the appimage
#   Github project
#   Github repo
#   Package string, partial string to identify which package to download in case several exist
#   Output dir, absolute path
#   Current version of the tool, or empty if not installed
# Returns:
#   0 if the installation was successful or already up-to-date, otherwise 1
function utils::install_github_appimage() {
    local -r toolname="$1"
    local -r github_project="$2"
    local -r github_repo="$3"
    local -r package_type="$4"
    local -r output_dir="$5"
    local -r current_version="${6:-}"

    __log_info "Trying to install ${toolname} using AppImage"

    if ! package=$(utils::download_github_release "${github_project}" "${github_repo}" "${package_type}" "${output_dir}" "${current_version}"); then
        __log_error "Failed to install appimage ${github_project}/${github_repo}"
        return 1
    elif [[ -z "${package}" ]]; then
        return 0
    fi

    # Make the AppImage executable and make it available as toolname using a symbolic link
    if ! run_cmd chmod +x "${package}"; then
        __log_error "Failed to make AppImage ${package} executable"
        return 1
    fi

    if ! run_cmd ln -sf "${package}" "${output_dir}/${toolname}"; then
        __log_error "Failed to create a symbolic link named ${toolname} to the AppImage ${package}"
        return 1
    fi
    return 0
}
