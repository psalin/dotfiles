#!/bin/bash

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Do not list all commands when pressing tab on an empty line
shopt -s no_empty_cmd_completion

# Append to history file instead of overwriting
shopt -s histappend

# Features supported by version 4
if [[ "${BASH_VERSINFO[0]}" -gt 3 ]]; then

    # List files when pressing TAB on empty line
    complete -f -E

    # Enable changing dirs without writing 'cd'
    shopt -s autocd

    # Check jobs before exiting
    shopt -s checkjobs

    # Correct minor spelling errors on dirs when completing
    shopt -s dirspell
fi

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
