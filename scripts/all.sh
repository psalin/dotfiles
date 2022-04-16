#!/bin/bash

# Installs all by running all scripts

set -euo pipefail

__log_info "Installing all\n"

run_script all-nonui || true
run_script desktop || true
