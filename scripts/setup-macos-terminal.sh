#!/usr/bin/env bash
set -euo pipefail

profile_name='BaseNvim OneDark Warmer'
font_postscript_name='JetBrainsMonoNFM-Regular'
font_size=14

if [[ $(uname -s) != 'Darwin' ]]; then
  echo 'This script configures macOS Terminal.app.' >&2
  exit 1
fi

if ! find "$HOME/Library/Fonts" -maxdepth 1 -iname 'JetBrainsMono*NerdFontMono-Regular.ttf' -print -quit 2>/dev/null | grep -q .; then
  if ! command -v brew >/dev/null 2>&1; then
    echo 'Homebrew is required to install JetBrainsMono Nerd Font.' >&2
    exit 1
  fi
  brew install --cask font-jetbrains-mono-nerd-font
fi

if ! defaults read com.apple.Terminal 'Window Settings' 2>/dev/null | grep -Fq "$profile_name"; then
  profile_tmp=$(mktemp -d "${TMPDIR:-/tmp}/BaseNvim-Terminal.XXXXXX")
  profile_file="$profile_tmp/$profile_name.terminal"
  trap 'rm -rf -- "$profile_tmp"' EXIT

  osascript -l JavaScript - "$profile_file" <<'JXA'
ObjC.import('AppKit')
ObjC.import('Foundation')

function rgb(hex) {
  const value = parseInt(hex.slice(1), 16)
  return $.NSColor.colorWithSRGBRedGreenBlueAlpha(
    ((value >> 16) & 255) / 255,
    ((value >> 8) & 255) / 255,
    (value & 255) / 255,
    1
  )
}

function archive(object) {
  return $.NSKeyedArchiver.archivedDataWithRootObject(object)
}

function run(argv) {
  const destination = argv[0]
  const colors = {
    BackgroundColor: '#232326',
    TextColor: '#a7aab0',
    TextBoldColor: '#a7aab0',
    CursorColor: '#a7aab0',
    SelectionColor: '#37383d',
    ANSIBlackColor: '#101012',
    ANSIRedColor: '#de5d68',
    ANSIGreenColor: '#8fb573',
    ANSIYellowColor: '#dbb671',
    ANSIBlueColor: '#57a5e5',
    ANSIMagentaColor: '#bb70d2',
    ANSICyanColor: '#51a8b3',
    ANSIWhiteColor: '#a7aab0',
    ANSIBrightBlackColor: '#5a5b5e',
    ANSIBrightRedColor: '#de5d68',
    ANSIBrightGreenColor: '#8fb573',
    ANSIBrightYellowColor: '#dbb671',
    ANSIBrightBlueColor: '#57a5e5',
    ANSIBrightMagentaColor: '#bb70d2',
    ANSIBrightCyanColor: '#51a8b3',
    ANSIBrightWhiteColor: '#a7aab0'
  }

  const profile = $.NSMutableDictionary.alloc.init
  profile.setObjectForKey($('BaseNvim OneDark Warmer'), $('name'))
  profile.setObjectForKey($('Window Settings'), $('type'))
  profile.setObjectForKey($('2.07'), $('ProfileCurrentVersion'))
  profile.setObjectForKey(archive($.NSFont.userFixedPitchFontOfSize(14)), $('Font'))
  profile.setObjectForKey(true, $('FontAntialias'))
  profile.setObjectForKey(false, $('UseBrightBold'))

  Object.keys(colors).forEach(function (key) {
    profile.setObjectForKey(archive(rgb(colors[key])), $(key))
  })

  if (!profile.writeToFileAtomically(destination, true)) {
    throw new Error('Could not write Terminal profile')
  }
}
JXA

# Opening a .terminal file imports the named profile without manual preference
# editing. A short poll waits for Terminal to persist the import.
  open -a Terminal "$profile_file"

  for _ in {1..40}; do
    if defaults read com.apple.Terminal 'Window Settings' 2>/dev/null | grep -Fq "$profile_name"; then
      break
    fi
    sleep 0.1
  done
fi

if ! defaults read com.apple.Terminal 'Window Settings' 2>/dev/null | grep -Fq "$profile_name"; then
  echo "Terminal did not import the '$profile_name' profile." >&2
  exit 1
fi

defaults write com.apple.Terminal 'Default Window Settings' -string "$profile_name"
defaults write com.apple.Terminal 'Startup Window Settings' -string "$profile_name"

# Terminal profiles store the font separately from the imported color archive.
# Use Terminal's supported scripting interface so the installed Nerd Font is
# selected by its PostScript name.
osascript \
  -e 'tell application "Terminal"' \
  -e "set targetProfile to settings set \"$profile_name\"" \
  -e "set font name of targetProfile to \"$font_postscript_name\"" \
  -e "set font size of targetProfile to $font_size" \
  -e 'set default settings to targetProfile' \
  -e 'set startup settings to targetProfile' \
  -e 'end tell'

echo "Installed '$profile_name' with JetBrainsMono Nerd Font."
echo 'Open a new Terminal window, then run: tmux && nvim'
