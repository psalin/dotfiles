#!/bin/bash

# Installs non-UI related tools

set -euo pipefail

__log_info "Installing all non-UI tools\n"

run_script basepackages || true
run_script emacs || true
run_script tmux || true
run_script zoxide || true
run_script bat || true
run_script fzf || true

run_script asdf || true
