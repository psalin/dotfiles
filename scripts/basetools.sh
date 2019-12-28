#!/bin/bash

# Runs the following scripts:
#   basepackages
#   emacs
#   fzf

set -euo pipefail

: "${script_dir:?}"

__log_info "Installing basetools"

. "${script_dir}"/basepackages.sh || true
. "${script_dir}"/emacs.sh || true
. "${script_dir}"/fzf.sh || true
