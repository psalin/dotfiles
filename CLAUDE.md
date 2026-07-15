# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Personal dotfiles plus environment-setup scripts, driven by **dotmgr** (a git submodule at `.dotmgr/`, from https://github.com/psalin/dotmgr). `install.sh` is the entry point: it syncs the submodule and delegates all arguments to `.dotmgr/dotmgr.sh --conffile dotfiles.conf`.

## Commands

```shell
./install.sh --dotfiles          # Symlink everything under dotfiles/ into $HOME
./install.sh -s <name>           # Run scripts/<name>.sh (e.g. -s emacs, -s tmux, -s all)
./install.sh -s asdf install-tool <tool>   # Script with arguments
./install.sh -P <package>        # Install an apt package
./install.sh --dry-run ...       # Log what would happen without executing
```

`scripts/help.sh` lists all available scripts (also shown by `./install.sh` with no args).

Lint (this is what CI runs — CircleCI runs shellcheck on all shell scripts):

```shell
shellcheck scripts/*.sh install.sh
```

`.shellcheckrc` disables SC1090/SC1091 because scripts are sourced dynamically. There are no tests; `--dry-run` is the way to sanity-check behavior.

## Architecture

- **`dotfiles.conf`** — configuration read (sourced) by dotmgr: maps `dotfiles/ → $HOME`, points at `scripts/`, sets the log file (`log/dotmgr.log`).
- **`dotfiles/`** — mirror of `$HOME`. Every *file* in this tree gets symlinked to the same relative path under `$HOME` (directories are recreated, not symlinked; existing real files are backed up as `*_YYYYMMDD.bak`). Adding a new config file just means placing it at the right path here and re-running `--dotfiles`.
- **`scripts/`** — installation scripts. They are **sourced by dotmgr, not executed**, so they run inside dotmgr's environment and rely on functions dotmgr provides: `run_cmd` (executes a command, honors `--dry-run`, redirects output to the log), `run_script <name> [args]` (invokes another script, used by `all.sh`/`all-nonui.sh` for composition), `install_packages`, and the `__log_info`/`__log_success`/`__log_warning`/`__log_error` loggers. Return non-zero on failure rather than exiting.
- **`scripts/utils.inc.sh`** — shared helpers sourced explicitly by scripts that need them (`source "${dir_path}/utils.inc.sh"`): version comparison and installing tools from snap, GitHub releases, or AppImages, always version-checked so re-runs are idempotent.

## Conventions

- Scripts follow the pattern: shebang + comment describing what gets installed, `set -euo pipefail`, functions, then top-level calls at the bottom.
- Everything is written to be idempotent — check current state/version before installing, and log skips with `__log_info`.
- Command output goes to `log/dotmgr.log` via `run_cmd`; user-facing status goes through the `__log_*` functions.
- `.dotmgr/` is a submodule; changes to the framework itself belong in the dotmgr repo, then bump the submodule here (see commit `aeddb22` for the pattern).
