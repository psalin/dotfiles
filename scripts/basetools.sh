#!/bin/bash

# Runs the following scripts:
#   basepackages
#   emacs
#   fzf

set -euo pipefail

__log_info "Installing basetools\n"

run_script basepackages || true
run_script emacs || true
run_script fzf || true
