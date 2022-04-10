#!/bin/bash

function show_script_help() {
    cat <<EOF

Available scripts:
  -s all                Runs all scripts, installing all tools
  -s all-nonui          Runs all scripts, except UI related ones
  -s basetools          Runs scripts basepackages, emacs and fzf

  -s asdf               Install asdf
  -s basepackages       Install base packages
  -s emacs              Install emacs
  -s fzf                Install fzf
  -s i3                 Install i3
  -s kube-ps1           Install kube-ps1
EOF
}

show_script_help
