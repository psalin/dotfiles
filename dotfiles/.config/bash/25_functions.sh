#!/bin/bash

# ls when a directory, less when a file
unalias l 2>/dev/null
function l() {
    if [  -z "$1" ]; then
        ls -lFa --color=auto;
    elif [ -d "$1" ]; then
        ls -lFa --color=auto "$@";
    else
        less -M -d -Q -i -C "$@";
    fi
}

# Opens the newest file in dir
function less_newest()
{
    find "$1" -maxdepth 1 -type "f" -printf "%T@ %p\n" | sort -n | cut -d' ' -f 2- | tail -n 1 | xargs less
}

# De-duplicates the bash history file
function dedup_history() {
    local histfile="${HISTFILE}"
    local tmpfile="${histfile}.$$"

    tac "${histfile}" | awk '!seen[$0]++' | tac > "${tmpfile}" && 'cp' -f "${histfile}" "${histfile}".bck && 'mv' -f "${tmpfile}" "${histfile}"
}

# Stuff to do on shell exit
function on_exit() {
    dedup_history # De-duplicate history file
}

trap on_exit EXIT
