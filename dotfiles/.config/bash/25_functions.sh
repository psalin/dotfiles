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

# notify-when-done, sends a OSC 777 notification after a command, if it
# exceeds NWD_THRESHOLD. Works for single command, wrap multi-command
# sequences in bash -c
#
# Examples:
# nwd my-command myparam
# nwd bash -c "my-command | my-other-command"
nwd() {
    local threshold=${NWD_THRESHOLD:-60}

    local start end duration exit_code
    start=$(date +%s)

    # Run the command
    "$@"
    exit_code=$?

    end=$(date +%s)
    local duration=$((end - start))

    if (( duration >= threshold )); then
	status=$([[ $exit_code -eq 0 ]] && echo "✓" || echo "✗")
        local title="${status} Command finished"
        local body="${*:1} ($duration seconds)"

        _send_osc777 "$title" "$body"
    fi

    return $exit_code
}

_send_osc777() {
    local title="$1"
    local body="$2"

    # Check if we're in tmux
    if [[ -n "$TMUX" ]]; then
        # In tmux, wrap with tmux escape sequence
        printf '\033Ptmux;\033\033]777;notify;%s;%s\007\033'\\ "$title" "$body" > /dev/tty
    else
        # Outside tmux, send directly
        printf '\033]777;notify;%s;%s\007' "$title" "$body" > /dev/tty
    fi
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
