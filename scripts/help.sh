#!/bin/bash

function show_script_help() {
    cat <<EOF

Available scripts:
  -s all                Runs all scripts, installing all tools
  -s all-nonui          Runs all scripts, except UI related ones
  -s basetools          Runs scripts basepackages, emacs and fzf

  -s asdf               Install asdf
  -s basepackages       Install base packages
  -s desktop            Install i3 and other desktop related software
  -s emacs              Install emacs
EOF
}

show_script_help
