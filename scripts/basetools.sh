#!/bin/bash

# Runs the following scripts:
#   basepackages
#   emacs
#   fzf

set -euo pipefail

: "${script_dir:?}"

__log_info "Installing basetools\n"

run_script basepackages
run_script emacs
run_script fzf
