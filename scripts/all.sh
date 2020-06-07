#!/bin/bash

# Installs all by running all scripts

set -euo pipefail

__log_info "Installing all\n"

run_script basepackages || true
run_script emacs || true
run_script fzf || true
run_script asdf || true
run_script kube-ps1 || true
