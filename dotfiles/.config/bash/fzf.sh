#!/bin/bash

if [[ -f "${HOME}"/.fzf.bash ]]; then
    source ~/.fzf.bash

    export FZF_DEFAULT_OPTS='-e'
fi
