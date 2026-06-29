#!/usr/bin/env bash
set -euo pipefail

profile_uuid='b23d880e-57f1-4d74-956b-9b75cf34a2e1'
profile_name='BaseNvim OneDark Warmer'
profile_schema="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/"
font_family='JetBrainsMono Nerd Font Mono'
font_size=13
font_version='3.4.0'

if [[ $(uname -s) != 'Linux' ]]; then
  echo 'This script configures Linux.' >&2
  exit 1
fi

for command_name in gsettings python3 fc-cache; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 1
  fi
done

if ! gsettings list-schemas | grep -Fxq 'org.gnome.Terminal.ProfilesList'; then
  echo 'GNOME Terminal was not detected. This script intentionally does not guess at another terminal emulator.' >&2
  exit 1
fi

if ! fc-match -f '%{family}\n' "$font_family" | head -1 | grep -Fq 'JetBrainsMono'; then
  setup_tmp=$(mktemp -d)
  trap 'rm -rf -- "$setup_tmp"' EXIT
  font_zip="$setup_tmp/JetBrainsMono.zip"
  font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  mkdir -p "$font_dir"

  if command -v curl >/dev/null 2>&1; then
    curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/download/v${font_version}/JetBrainsMono.zip" -o "$font_zip"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$font_zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v${font_version}/JetBrainsMono.zip"
  else
    echo 'Install curl or wget so the Nerd Font can be downloaded.' >&2
    exit 1
  fi

  if ! command -v unzip >/dev/null 2>&1; then
    echo 'Install unzip so the Nerd Font can be installed.' >&2
    exit 1
  fi
  unzip -qo "$font_zip" -d "$font_dir"
  fc-cache -f "$font_dir"
fi

current_profiles=$(gsettings get org.gnome.Terminal.ProfilesList list)
updated_profiles=$(python3 - "$current_profiles" "$profile_uuid" <<'PY'
import ast
import sys

raw_profiles = sys.argv[1]
if raw_profiles.startswith('@as '):
    raw_profiles = raw_profiles[4:]
profiles = ast.literal_eval(raw_profiles)
profile_uuid = sys.argv[2]
if profile_uuid not in profiles:
    profiles.append(profile_uuid)
print(repr(profiles))
PY
)

gsettings set org.gnome.Terminal.ProfilesList list "$updated_profiles"
gsettings set org.gnome.Terminal.ProfilesList default "'$profile_uuid'"
gsettings set "$profile_schema" visible-name "'$profile_name'"
gsettings set "$profile_schema" use-system-font false
gsettings set "$profile_schema" font "'$font_family $font_size'"
gsettings set "$profile_schema" use-theme-colors false
gsettings set "$profile_schema" foreground-color "'#a7aab0'"
gsettings set "$profile_schema" background-color "'#232326'"
gsettings set "$profile_schema" bold-color-same-as-fg true
gsettings set "$profile_schema" cursor-colors-set true
gsettings set "$profile_schema" cursor-background-color "'#a7aab0'"
gsettings set "$profile_schema" cursor-foreground-color "'#232326'"
gsettings set "$profile_schema" highlight-colors-set true
gsettings set "$profile_schema" highlight-background-color "'#37383d'"
gsettings set "$profile_schema" highlight-foreground-color "'#a7aab0'"
gsettings set "$profile_schema" palette "['#101012', '#de5d68', '#8fb573', '#dbb671', '#57a5e5', '#bb70d2', '#51a8b3', '#a7aab0', '#5a5b5e', '#de5d68', '#8fb573', '#dbb671', '#57a5e5', '#bb70d2', '#51a8b3', '#a7aab0']"

echo "Installed '$profile_name' with JetBrainsMono Nerd Font."
echo 'Open a new GNOME Terminal window, then run: tmux && nvim'
