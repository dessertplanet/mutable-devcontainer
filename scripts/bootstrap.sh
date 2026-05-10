#!/usr/bin/env bash
# bootstrap.sh — onCreateCommand for the devcontainer.
# Clones the Mutable Instruments eurorack repo and initialises submodules.
set -euo pipefail

WORKSPACE="${1:-/workspaces/mutable-dev-environment}"
WORKING_DIR_NAME="eurorack-modules"
DEV_ENV="${WORKSPACE}/${WORKING_DIR_NAME}"
MI_REPO="https://github.com/pichenettes/eurorack.git"

if [ -d "$DEV_ENV" ]; then
    echo "⚠  ${DEV_ENV} already exists — skipping clone."
else
    USER_GITHUB_URL="${USER_GITHUB_URL:-}"
    cd "$WORKSPACE"
    if [ -n "$USER_GITHUB_URL" ]; then
        git clone "$USER_GITHUB_URL" "$WORKING_DIR_NAME"
        cd "$DEV_ENV"
        git remote add pichenettes "$MI_REPO"
    else
        git clone "$MI_REPO" "$WORKING_DIR_NAME"
        cd "$DEV_ENV"
    fi
    git submodule init
    git submodule update
fi

# cd to the code directory on terminal open
grep -qxF "cd ${DEV_ENV}" "$HOME/.bashrc" 2>/dev/null \
    || echo "cd ${DEV_ENV}" >> "$HOME/.bashrc"

echo "✔  Bootstrap complete.  Source code is at ${DEV_ENV}"
