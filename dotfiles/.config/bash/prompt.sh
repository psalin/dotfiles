#!/bin/bash

# Prompt with git branch
function parse_git_branch {
    git branch --no-color 2>/dev/null | 'grep' -E '[*]' | sed "s/\* \(.*\)/ (\1)/"
}

MY_TITLEBAR="\[\e]0;\u@\h: \w\$(parse_git_branch)\a\]"
MY_PROMPT="(\[\e[1;34m\]\h\[\e[0m\])\$(parse_git_branch) \[\e[1m\]\w\[\e[0m\]\n>"
PS1="$MY_TITLEBAR""$MY_PROMPT"
