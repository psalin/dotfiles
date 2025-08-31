# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Explicitly set XDG variables
export XDG_CONFIG_HOME="${HOME}"/.config
export XDG_CACHE_HOME="${HOME}"/.cache
export XDG_DATA_HOME="${HOME}"/.local/share
export XDG_STATE_HOME="${HOME}"/.local/state

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source bashrc configuration files
config_dir="${HOME}/.config/bash"

if [[ -d "${config_dir}" ]]; then
    for file in "${config_dir}"/*; do
        if [ -f "${file}" ]; then
            source "${file}"
        fi
    done
fi

# Source extra bashrc configuration files
extra_config_dir="${HOME}/.config/bash/local"

if [[ -d "${extra_config_dir}" ]]; then
    for file in "${extra_config_dir}"/*; do
        if [ -f "${file}" ]; then
            source "${file}"
        fi
    done
fi
