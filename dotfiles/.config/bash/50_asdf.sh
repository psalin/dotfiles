#!/bin/bash

if [[ -x "$(command -v asdf)" ]]; then
    export ASDF_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/asdf"
    export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
    . <(asdf completion bash)
fi
