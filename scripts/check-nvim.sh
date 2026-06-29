#!/usr/bin/env bash
set -euo pipefail

check_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check_tmp="$(mktemp -d)"
trap 'rm -rf "$check_tmp"' EXIT

mkdir -p "$check_tmp/state" "$check_tmp/cache" "$check_tmp/runtime"
chmod 700 "$check_tmp/runtime"
cd "$check_root"

export BASENVIM_INIT="$check_root/init.lua"
NVIM_LOG_FILE="$check_tmp/nvim.log" \
XDG_STATE_HOME="$check_tmp/state" \
XDG_CACHE_HOME="$check_tmp/cache" \
XDG_RUNTIME_DIR="$check_tmp/runtime" \
nvim --headless -u "$check_root/scripts/check-init.lua" -i NONE
