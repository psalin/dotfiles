#!/bin/bash

# Runs the following scripts:
#   basepackages
#   emacs
#   fzf

set -euo pipefail

__log_info "Installing basetools\n"

run_script basepackages
run_script emacs
run_script fzf
