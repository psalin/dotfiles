#!/bin/bash

# Runs the following scripts:
#   basepackages
#   emacs
#   fzf

set -euo pipefail

: "${script_dir:?}"

__log_info "Installing basetools"

# shellcheck source=/dev/null
. "${script_dir}"/basepackages.sh || true

# shellcheck source=/dev/null
. "${script_dir}"/emacs.sh || true

# shellcheck source=/dev/null
. "${script_dir}"/fzf.sh || true
