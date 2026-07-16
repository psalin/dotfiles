#!/bin/bash

function show_script_help() {
    cat <<EOF

Available scripts:
  -s all                                Runs all scripts, installing all tools
  -s all-nonui                          Runs all scripts, except UI related ones

  -s asdf                               Install asdf
  -s asdf install-tool <toolname>       Install <toolname> using asdf
  -s basepackages                       Install base packages
  -s bat                                Install bat
  -s desktop                            Install regolith and other desktop related software
  -s emacs                              Install emacs
  -s fzf                                Install fzf
  -s tmux                               Install tmux
  -s zoxide                             Install zoxide
EOF
}

show_script_help
