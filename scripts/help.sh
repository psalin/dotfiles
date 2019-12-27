#!/bin/bash

function show_script_help() {
    cat <<EOF

Available scripts:
  -s basetools          Install base tools (emacs, fzf)
  -s emacs              Install emacs
  -s fzf                Install fzf
EOF
}

show_script_help
