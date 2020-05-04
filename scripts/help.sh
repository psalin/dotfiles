#!/bin/bash

function show_script_help() {
    cat <<EOF

Available scripts:
  -s basetools          Runs scripts basepackages, emacs and fzf

  -s asdf               Install asdf
  -s basepackages       Installs base packages
  -s emacs              Install emacs
  -s fzf                Install fzf
EOF
}

show_script_help
