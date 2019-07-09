#!/bin/bash

set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG="dotfiles.conf"

DOTMGR_DIR=".dotmgr"
DOTMGR_BIN="dotmgr.sh"

cd "${BASEDIR}"

git -C "${DOTMGR_DIR}" submodule sync --quiet --recursive
git submodule update --init --recursive "${DOTMGR_DIR}"

"${BASEDIR}/${DOTMGR_DIR}/${DOTMGR_BIN}" --conffile "${CONFIG}" "${@}"
