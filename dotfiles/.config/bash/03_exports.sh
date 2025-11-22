#!/bin/bash

# Put bash history file under XDG
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
# Use emacs as default editor
export EDITOR="emacs -nw -q"
# Default less options
# -d suppress dumb terminal error prints
# -i ignore case when searching
# -M long-prompt, more info in the status prompt
# -Q quiet, don't ring the terminal bell
# -R lets ANSI color escape sequences be interpreted
export LESS=diMQR
# Put less history file under XDG
export LESSHISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/less/history"
# Make other-writable directories be listed in colors that can be read
export LS_COLORS="${LS_COLORS}ow=1;97;45:"
