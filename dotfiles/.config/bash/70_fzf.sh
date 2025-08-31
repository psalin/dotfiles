#!/bin/bash

if [[ -x "$(command -v fzf)" ]]; then
    eval "$(fzf --bash)"
    export FZF_DEFAULT_OPTS='--exact'
fi
