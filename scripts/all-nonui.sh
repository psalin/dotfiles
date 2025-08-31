#!/bin/bash

# Installs all non UI scripts

set -euo pipefail

__log_info "Installing all non-UI tools\n"

run_script basepackages || true
run_script emacs || true
run_script asdf || true
run_script kube-ps1 || true
run_script asdf install-tool fzf || true
