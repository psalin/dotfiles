# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source bashrc configuration files
config_dir="${HOME}/.config/bash"

if [[ -d "${config_dir}" ]]; then
    for file in "${config_dir}"/*; do
        source "${file}"
    done
fi

# Source extra bashrc configuration files
extra_config_dir="${HOME}/.config/bash/local"

if [[ -d "${extra_config_dir}" ]]; then
    for file in "${extra_config_dir}"/*; do
        source "${file}"
    done
fi
