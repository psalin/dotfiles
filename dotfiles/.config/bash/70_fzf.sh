#!/bin/bash

if [[ -x "$(command -v fzf)" ]]; then
    eval "$(fzf --bash)"
    export FZF_DEFAULT_OPTS='--exact --ansi --bind home:first,end:last,ctrl-k:kill-line,alt-d:clear-query'
fi
