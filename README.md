# BaseNvim

A bare-bones Neovim config with terminal setup included for Linux and macOS.
BaseNvim is deliberately a pure “super text editor”: optimized Vim workflows
and modern text tooling, without LSPs, completion, autocorrect, or AI.

tmux handles terminal panes in macOS Terminal.app and the default Linux terminal.
`Ctrl+H/J/K/L` moves between Neovim windows and tmux panes.

Native vim.pack · fzf-lua · Snacks Explorer · Quicker · mini.icons · OneDark Warmer · heirline · GitLab.nvim

Requires Neovim 0.12+, tmux 3.3+, fzf 0.36+, tree-sitter-cli 0.26.1+,
ImageMagick, Go 1.25.1+, and the tmux plugin manager (TPM).

## macOS setup

Use the built-in Terminal.app. The tracked setup script installs the Nerd Font
when needed, imports a matching OneDark Warmer profile, and makes it the default.

```bash
# 1. Dependencies
brew install neovim tmux git ripgrep fd make go node fzf tree-sitter-cli imagemagick

# 2. Clone this repo, then run the rest from inside it
git clone <this-repo-url> BaseNvim && cd BaseNvim

# 3. Terminal font and colors (opens Terminal once to import the profile)
./scripts/setup-macos-terminal.sh

# 4. tmux config (back up a regular file, then symlink the tracked config)
if [ -e ~/.tmux.conf ] || [ -L ~/.tmux.conf ]; then mv ~/.tmux.conf ~/.tmux.conf.bak; fi
ln -s "$(pwd)/tmux/tmux.conf" ~/.tmux.conf
if [ ! -d ~/.tmux/plugins/tpm/.git ]; then git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; fi
~/.tmux/plugins/tpm/bin/install_plugins

# 5. Shell config (prepends vi mode + fzf to the existing zshrc)
{ cat ./shell/zshrc; cat ~/.zshrc 2>/dev/null; } > ~/.zshrc.new && mv ~/.zshrc.new ~/.zshrc && source ~/.zshrc

# 6. Neovim config
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
ln -s "$(pwd)" ~/.config/nvim

# 7. Open a new Terminal window, start tmux, then launch Neovim.
tmux
nvim
```

## Linux setup

The automated terminal profile targets GNOME Terminal, the Ubuntu desktop
default. The package examples also target Ubuntu; adjust them for another
distribution.

```bash
# 1. Dependencies
sudo apt update
sudo apt install -y tmux openssh-client git ripgrep fd-find build-essential clang libclang-dev curl fzf unzip wl-clipboard xclip imagemagick fontconfig python3

# GitLab.nvim requires Go >= 1.25.1. Ubuntu's package can be too old, so install
# the current Go release directly from https://go.dev/dl/ instead.
go_version='1.26.6'
case "$(uname -m)" in
  x86_64) go_arch='amd64'; go_sha256='708effb774be8237570d0add163225abbdfaf4fca28b2611df167beba4feef89' ;;
  aarch64|arm64) go_arch='arm64'; go_sha256='d0507e9e9d7fe012aae570108cbd76c15de879e17130ab8cb90d4d7445cb1f2e' ;;
  *) echo "Unsupported Go architecture: $(uname -m)" >&2; return 1 2>/dev/null || exit 1 ;;
esac
go_archive="go${go_version}.linux-${go_arch}.tar.gz"
curl -fLO "https://go.dev/dl/${go_archive}"
printf '%s  %s\n' "$go_sha256" "$go_archive" | sha256sum --check
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$go_archive"
rm -f "$go_archive"
export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
go version

# Ubuntu's cargo/rustc packages can be too old for tree-sitter-cli, so install
# the current stable Rust toolchain with rustup instead.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
. "$HOME/.cargo/env"
rustc --version

# nvim-treesitter main requires tree-sitter-cli >= 0.26.1 (do not install it with npm).
cargo install tree-sitter-cli --locked

# Install latest Neovim (this config requires v0.12+)
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install -y neovim

# Install nvm and Node.js 22 (do not use apt's nodejs/npm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22
nvm alias default 22

# 2. Clone this repo, then run the rest from inside it
cd ~
git clone <this-repo-url> BaseNvim && cd BaseNvim

# 3. GNOME Terminal font and colors
./scripts/setup-linux-terminal.sh

# 4. tmux config
if [ -e ~/.tmux.conf ] || [ -L ~/.tmux.conf ]; then mv ~/.tmux.conf ~/.tmux.conf.bak; fi
ln -s "$(pwd)/tmux/tmux.conf" ~/.tmux.conf
if [ ! -d ~/.tmux/plugins/tpm/.git ]; then git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; fi
~/.tmux/plugins/tpm/bin/install_plugins

# 5. Shell config (prepends vi mode + fzf to the existing bashrc)
{ cat ./shell/bashrc; cat ~/.bashrc 2>/dev/null; } > ~/.bashrc.new && mv ~/.bashrc.new ~/.bashrc && source ~/.bashrc

# 6. Neovim config
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
ln -s "$(pwd)" ~/.config/nvim

# 7. Open a new terminal window, start tmux, then launch Neovim.
tmux
nvim
```

## tmux and navigation

The tmux prefix is `Ctrl+S`. Press and release the prefix, then press the next
key. Resizing is repeatable: after `Ctrl+S`, hold or continually press
`h/j/k/l` to keep moving the nearest Neovim-window or tmux-pane boundary in
that direction. This includes the Snacks file explorer.

| Key | Action |
|---|---|
| `Ctrl+S`, `%` | Split pane left/right (tmux default split key) |
| `Ctrl+S`, `"` | Split pane top/bottom (tmux default split key) |
| `Ctrl+S`, `c` | New tmux window |
| `Ctrl+S`, `n` / `p` | Next / previous tmux window |
| `Ctrl+S`, `C` | Kill current tmux window |
| `Ctrl+S`, `x` | Kill current tmux pane |
| `Ctrl+S`, `z` | Zoom / unzoom current pane |
| `Ctrl+S`, `d` | Detach from tmux |
| `Ctrl+S`, `i` | Show the current session, window, and pane |
| `Ctrl+S`, `s` / `w` | Browse sessions / windows |
| `Ctrl+S`, `$` | Rename the current session |
| `Ctrl+S`, `S` / `R` | Save / restore tmux sessions and pane layouts |
| `Ctrl+S`, `r` | Reload `~/.tmux.conf` |
| `Ctrl+H/J/K/L` | Navigate between Neovim windows and tmux panes |
| `Ctrl+S`, then `h/j/k/l` | Repeatedly resize Neovim or tmux left/down/up/right |
| `<Space>\` / `<Space>-` | New Neovim split left/right or top/bottom |
| `<Space>w` | Close current Neovim window |

Useful session commands:

```bash
tmux                         # create a session
tmux new -s project          # create a named session
tmux attach                  # attach to the most recent session
tmux attach -t project       # attach to a named session
tmux ls                      # list sessions
```

Use one named session per project. tmux-resurrect preserves session names,
windows, pane layouts, working directories, and its conservative program list
across tmux or machine restarts. Save with `Ctrl+S`, `S` and restore with
`Ctrl+S`, `R`. It relaunches Neovim but deliberately does not add a second
Neovim session manager or attempt to reconstruct unsaved editor state.

TPM manages the resurrect plugin. After adding or changing tmux plugins, use
`Ctrl+S`, `I` to install and `Ctrl+S`, `U` to update them. The persistent status
bar remains disabled, so automatic tmux-continuum snapshots are intentionally
not enabled.

### Copy mode

Press `Ctrl+S`, then `[` to enter vi copy mode. Move with vi keys, press `v` to
start a selection, and `y` to copy it to the system clipboard. Rectangle select
is `Ctrl+V`. Mouse selections also copy on release. The config uses macOS's
`pbcopy`, Wayland's `wl-copy`, or X11's `xclip` rather than requiring OSC 52
support from the terminal.

## Neovim

Leader is `<Space>`. Press `<Space>` to see available bindings via which-key.

| Key | Action |
|---|---|
| `<Space>e` | Toggle file explorer |
| `<Space>E` / `<Space>C` | Add another root to the same explorer / clear added roots |
| `<Space>ff` / `<Space>fw` | Find files / live grep |
| `<Space>fc` (normal/visual) | Find word under cursor / selected text across the codebase |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<Space>x` | Close buffer |
| `<Space><Space>` | Find open buffers |
| `<Space>q` | Toggle the quickfix list (`>` / `<` expands / collapses context) |
| `]c` / `[c` | Next / previous git hunk |
| `<Space>gp/gi` | Preview hunk in a popup / inline |
| `<Space>gS/gU/gR` | Stage / undo stage / reset hunk |
| `<Space>gw` | Toggle word-level Git diff |
| `<Space>gq/gQ` | Current-buffer / repository hunks in quickfix |
| `ih` (operator/visual) | Select the current Git hunk |
| `<Space>gd/gc/gh/gH` | Diffview: open / close / file history / repo history |
| `<Space>gL` (visual) | History for selected lines |
| `<Space>fr` | Find and replace across codebase |
| `<Space>uu` | Browse the current buffer's visual undo tree |
| `<Space>ut` | Toggle sticky Treesitter scope context |
| `<Space>um` | Toggle rendered Markdown in the current buffer |
| `<Space>ui` | Preview the image link under the cursor |
| `glc` / `glS` | Choose an open GitLab MR / review the current branch's MR |
| `glC` / `glA` / `glM` | Create / approve / merge a GitLab MR |

The explorer deliberately shows hidden files, gitignored files, build output,
and submodule contents. fzf-lua file and grep searches include hidden and
gitignored content but exclude `.git`, `build*`, and `node_modules` directories.

Trailing whitespace is trimmed when saving ordinary editable files. The config
skips whitespace-sensitive Markdown, diff, mail, and commit buffers, while a
project's explicit EditorConfig policy always takes precedence.

`<Space>uu` displays Neovim's native branching undo history with a diff preview;
move through states with `j`/`k` and press `Enter` to restore one. `<Space>ut`
toggles the sticky function/class/scope context, deliberately limited to two
lines.

### Images

Snacks renders an image opened with `Enter`/`l` inside Neovim and renders image
links inline in supported documents. `<Space>ui` previews the image link under
the cursor; Explorer's `o` always opens the file in the system image viewer.

Inline display requires a terminal with the Kitty graphics protocol. On Linux,
use Kitty or Ghostty with tmux 3.3+; the tracked tmux config enables graphics
passthrough. GNOME Terminal does not support the protocol, so use Explorer's
`o` there. The same limitation applies to macOS Terminal.app. WezTerm can show
image buffers but Snacks does not support inline document images in WezTerm.
ImageMagick converts non-PNG formats. See the
[Snacks.image documentation](https://github.com/folke/snacks.nvim/blob/main/docs/image.md)
for supported formats and terminals.

### Plugin updates

Plugins are managed by Neovim's native `vim.pack`. The committed
`nvim-pack-lock.json` records exact working revisions. Run `:PackUpdate`, review
the changes, use `:write` to accept or `:quit` to discard, then run `:restart`.

### Configuration check

Run `./scripts/check-nvim.sh` after structural config changes to verify a clean
headless startup without writing logs, cache files, or state into the repository.
Run it from the installed/symlinked config so native packages use its lockfile.

## Git workflow

Use gitsigns for in-buffer hunk navigation, preview, staging, and reset. Use
Diffview for reviewing changes and history, and use the regular `git` CLI in a
neighboring tmux pane for commits, branches, rebases, and remote operations.

### GitLab merge requests

GitLab.nvim stays dormant during ordinary startup. The first `gl…` action
initializes it and starts its local Go helper; later GitLab actions reuse it.

Create a GitLab personal access token with API access and expose it to Neovim
through the shell environment. Do not commit the token to this repository:

```bash
export GITLAB_TOKEN="your_gitlab_token"
# Self-hosted GitLab only:
export GITLAB_URL="https://gitlab.example.com/"
```

Open a GitLab-backed repository and press `glc` to choose an open merge request,
or check out an MR branch and press `glS` to start its review. In the review
windows, press `g?` for context-specific actions such as commenting and resolving
threads. Run `:checkhealth gitlab` if the local GitLab server or authentication
does not start.
