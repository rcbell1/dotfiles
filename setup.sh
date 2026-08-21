#!/usr/bin/env bash
#
# Sudo-free environment setup. Everything installs under ~/.local, so this
# script works on machines where you have no root access at all.
#
# Re-running it upgrades every managed tool to the latest upstream release,
# which is what replaces "apt upgrade" for these binaries.
#
# System prerequisites (git, curl, tar, xz, fontconfig, tmux, libx11) are NOT
# installed here because they need root. Run ./sudo_setup.sh once per machine
# if the preflight check below reports anything missing.
#
# The nerd font and the terminal colour scheme no longer need any manual setup:
# the "terminal" step delegates to terminal_setup.sh, which configures Windows
# Terminal on WSL (including registering the font for the Windows user) or
# GNOME Terminal on a native desktop. Restart the terminal afterwards so a
# newly registered font is picked up.
#
# On a native Ubuntu desktop, ./gnome_setup.sh applies the GNOME tweaks.

set -uo pipefail

PREFIX="$HOME/.local"
BIN="$PREFIX/bin"
OPT="$PREFIX/opt"
FONT_DIR="$PREFIX/share/fonts"
STAMP_DIR="$PREFIX/share/dotfiles-setup"
# Resolved with builtins only, so this still works before the preflight check
# has confirmed anything about the environment.
case "${BASH_SOURCE[0]}" in
*/*) _script_dir="${BASH_SOURCE[0]%/*}" ;;
*) _script_dir="." ;;
esac
DOTFILES="$(cd "$_script_dir" && pwd)"
unset _script_dir

# Local binaries must win over anything a previous sudo-based run left in
# /usr/bin, /usr/local/bin or /snap/bin, otherwise every check below would
# report the stale system copy as already installed.
export PATH="$BIN:$PATH"

MUSL_TARGET="x86_64-unknown-linux-musl"

FORCE=0
ONLY=""
STEP_STATUS=""
declare -a SUMMARY=()

if [ -t 1 ]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_DIM=$'\033[2m'
else
  C_RESET="" C_BOLD="" C_GREEN="" C_YELLOW="" C_RED="" C_DIM=""
fi

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Installs and updates a local development environment under ~/.local.
No sudo required. Safe to re-run; each tool is upgraded only when a newer
upstream release exists.

Options:
  --force          Reinstall every tool even if it is already up to date
  --only a,b,c     Only run the named steps (comma separated)
  --list           List the available step names and exit
  -h, --help       Show this help and exit

Environment:
  GITHUB_TOKEN     Optional. Raises the GitHub API rate limit used for
                   release version lookups (60/hour when unauthenticated).

Examples:
  ./setup.sh                    # install or update everything
  ./setup.sh --only nvim,ripgrep
  ./setup.sh --force --only xclip
EOF
}

STEPS="starship nvim lazygit ripgrep bat fd node uv fzf tpm font xclip wl-clipboard git-helpers dotlinks terminal screen-blank"

while [ $# -gt 0 ]; do
  case $1 in
  --force) FORCE=1 ;;
  --only)
    shift
    ONLY="${1:-}"
    [ -n "$ONLY" ] || {
      echo "--only requires a value" >&2
      exit 2
    }
    ;;
  --only=*) ONLY="${1#*=}" ;;
  --list)
    printf '%s\n' "$STEPS" | tr ' ' '\n'
    exit 0
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 2
    ;;
  esac
  shift
done

WORK=""

info() { printf '%s==>%s %s\n' "$C_BOLD" "$C_RESET" "$*"; }
detail() { printf '    %s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }
warn() { printf '%swarning:%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err() { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }

is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] ||
    grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null
}

# ---------------------------------------------------------------------------
# Preflight: these need root to install, so point at sudo_setup.sh instead of
# escalating. Missing soft dependencies only disable the steps that need them.
# ---------------------------------------------------------------------------

preflight() {
  local missing=() soft=()
  local cmd
  for cmd in git curl tar; do
    have_cmd "$cmd" || missing+=("$cmd")
  done
  for cmd in xz fc-cache apt-get dpkg-deb; do
    have_cmd "$cmd" || soft+=("$cmd")
  done

  if [ ${#missing[@]} -gt 0 ]; then
    err "missing required commands: ${missing[*]}"
    err "run ./sudo_setup.sh first (it needs sudo), then re-run this script"
    exit 1
  fi
  if [ ${#soft[@]} -gt 0 ]; then
    warn "missing optional commands: ${soft[*]}"
    warn "some steps will be skipped; ./sudo_setup.sh installs these"
  fi
}

# ---------------------------------------------------------------------------
# Version helpers
# ---------------------------------------------------------------------------

# Latest release tag for a GitHub repo, e.g. gh_latest sharkdp/bat -> v0.26.1
gh_latest() {
  local repo=$1
  local -a hdr=()
  [ -n "${GITHUB_TOKEN:-}" ] && hdr=(-H "Authorization: Bearer $GITHUB_TOKEN")
  curl -fsSL --max-time 30 "${hdr[@]+"${hdr[@]}"}" \
    "https://api.github.com/repos/$repo/releases/latest" |
    grep -Po '"tag_name":\s*"\K[^"]*'
}

# Version strings are compared with any leading "v" removed, because ripgrep
# tags as 15.2.0 while bat, fd and lazygit tag as v0.26.1.
up_to_date() {
  local have=${1#v} want=${2#v}
  [ "$FORCE" -eq 0 ] && [ -n "$have" ] && [ -n "$want" ] && [ "$have" = "$want" ]
}

mark_done() {
  if [ -n "${1:-}" ]; then STEP_STATUS="UPDATED"; else STEP_STATUS="INSTALLED"; fi
}

# Run a version command against the copy in ~/.local, not whatever PATH happens
# to resolve first. Without this, a same-version system copy (a snap nvim, an
# apt bat) would satisfy the check and the local install would never happen.
owned_ver() {
  local exe="$BIN/$1"
  shift
  [ -e "$exe" ] || return 0
  "$exe" "$@" 2>/dev/null
}

# The nerd font and the extracted debs carry no queryable version, so the
# resolved upstream version is recorded here instead.
stamp_get() { cat "$STAMP_DIR/$1.version" 2>/dev/null; }
stamp_set() {
  mkdir -p "$STAMP_DIR" && printf '%s\n' "$2" >"$STAMP_DIR/$1.version"
}

# Download a tarball and install a single binary out of it into ~/.local/bin.
extract_bin() {
  local url=$1 member=$2 strip=$3 name=$4
  local dir="$WORK/x-$name"
  rm -rf "$dir" && mkdir -p "$dir" || return 1
  curl -fsSL --max-time 300 "$url" |
    tar -xzf - -C "$dir" --strip-components="$strip" --wildcards "$member" ||
    return 1
  install -m 755 "$dir/$name" "$BIN/$name"
}

# Replace a directory tree atomically enough that a failed download cannot
# leave a half-extracted tool behind.
extract_tree() {
  local url=$1 dest=$2 taropt=$3
  local new="$dest.new"
  rm -rf "$new" && mkdir -p "$new" || return 1
  if ! curl -fsSL --max-time 600 "$url" |
    tar "$taropt" -f - -C "$new" --strip-components=1; then
    rm -rf "$new"
    return 1
  fi
  rm -rf "$dest" && mv "$new" "$dest"
}

# ---------------------------------------------------------------------------
# Step runner
# ---------------------------------------------------------------------------

step() {
  local label=$1 fn=$2
  if [ -n "$ONLY" ] && [[ ",$ONLY," != *",$label,"* ]]; then
    return 0
  fi
  info "$label"
  STEP_STATUS=""
  local status
  if "$fn"; then
    status="${STEP_STATUS:-OK}"
  else
    status="FAILED"
  fi
  SUMMARY+=("$label:$status")
  case $status in
  FAILED) printf '    %s%s%s\n' "$C_RED" "$status" "$C_RESET" ;;
  UP-TO-DATE | PRESENT | SKIPPED) printf '    %s%s%s\n' "$C_DIM" "$status" "$C_RESET" ;;
  *) printf '    %s%s%s\n' "$C_GREEN" "$status" "$C_RESET" ;;
  esac
}

summarize() {
  local failed=0 entry label status
  printf '\n%sSummary%s\n' "$C_BOLD" "$C_RESET"
  for entry in "${SUMMARY[@]+"${SUMMARY[@]}"}"; do
    label=${entry%%:*}
    status=${entry#*:}
    [ "$status" = FAILED ] && failed=1
    printf '  %-14s %s\n' "$label" "$status"
  done
  printf '\n'
  if [ "$failed" -eq 1 ]; then
    warn "some steps failed; re-run to retry (network errors are usually transient)"
  fi
  info "open a new shell (or run: source ~/.bashrc) to pick up PATH changes"
  return "$failed"
}

# ---------------------------------------------------------------------------
# Installers
# ---------------------------------------------------------------------------

install_starship() {
  local latest have
  latest=$(gh_latest starship/starship) || return 1
  have=$(owned_ver starship --version | head -1 | awk '{print $2}')
  up_to_date "$have" "$latest" && {
    STEP_STATUS="UP-TO-DATE"
    return 0
  }
  curl -fsSL https://starship.rs/install.sh |
    sh -s -- -y -b "$BIN" >/dev/null || return 1
  mark_done "$have"
}

install_nvim() {
  local latest have
  latest=$(gh_latest neovim/neovim) || return 1
  have=$(owned_ver nvim --version | head -1 | awk '{print $2}')
  up_to_date "$have" "$latest" && {
    STEP_STATUS="UP-TO-DATE"
    return 0
  }
  local url="https://github.com/neovim/neovim/releases/download/$latest"
  url="$url/nvim-linux-x86_64.tar.gz"
  extract_tree "$url" "$OPT/nvim" -xz || return 1
  ln -sfn "$OPT/nvim/bin/nvim" "$BIN/nvim" || return 1
  mark_done "$have"
}

install_lazygit() {
  local latest have ver
  latest=$(gh_latest jesseduffield/lazygit) || return 1
  ver=${latest#v}
  # The leading comma matters: the output also carries "git version=2.43.0".
  have=$(owned_ver lazygit --version | grep -Po ', version=\K[^,]*' | head -1)
  up_to_date "$have" "$ver" && {
    STEP_STATUS="UP-TO-DATE"
    return 0
  }
  local url="https://github.com/jesseduffield/lazygit/releases/download/$latest"
  url="$url/lazygit_${ver}_Linux_x86_64.tar.gz"
  extract_bin "$url" lazygit 0 lazygit || return 1
  mark_done "$have"
}

install_ripgrep() {
  local latest have
  latest=$(gh_latest BurntSushi/ripgrep) || return 1
  have=$(owned_ver rg --version | head -1 | awk '{print $2}')
  up_to_date "$have" "$latest" && {
    STEP_STATUS="UP-TO-DATE"
    return 0
  }
  local base="ripgrep-${latest}-${MUSL_TARGET}"
  local url="https://github.com/BurntSushi/ripgrep/releases/download/$latest"
  url="$url/${base}.tar.gz"
  extract_bin "$url" '*/rg' 1 rg || return 1
  mark_done "$have"
}

install_bat() {
  local latest have
  latest=$(gh_latest sharkdp/bat) || return 1
  have=$(owned_ver bat --version | head -1 | awk '{print $2}')
  up_to_date "$have" "$latest" && {
    STEP_STATUS="UP-TO-DATE"
    return 0
  }
  local url="https://github.com/sharkdp/bat/releases/download/$latest"
  url="$url/bat-${latest}-${MUSL_TARGET}.tar.gz"
  extract_bin "$url" '*/bat' 1 bat || return 1
  mark_done "$have"
}

install_fd() {
  local latest have
  latest=$(gh_latest sharkdp/fd) || return 1
  have=$(owned_ver fd --version | head -1 | awk '{print $2}')
  up_to_date "$have" "$latest" && {
    STEP_STATUS="UP-TO-DATE"
    return 0
  }
  local url="https://github.com/sharkdp/fd/releases/download/$latest"
  url="$url/fd-${latest}-${MUSL_TARGET}.tar.gz"
  extract_bin "$url" '*/fd' 1 fd || return 1
  mark_done "$have"
}

# Replaces the NodeSource apt repo, which writes to /etc/apt/sources.list.d.
# Tracks Current (not LTS), matching the old setup_current.x behaviour.
install_node() {
  have_cmd xz || {
    STEP_STATUS="SKIPPED"
    warn "xz missing, cannot unpack the node tarball"
    return 0
  }
  local file ver have
  file=$(curl -fsSL --max-time 60 https://nodejs.org/dist/latest/SHASUMS256.txt |
    grep -oE 'node-v[0-9.]+-linux-x64\.tar\.xz' | head -1) || return 1
  [ -n "$file" ] || return 1
  ver=${file#node-}
  ver=${ver%%-linux*}
  have=$(owned_ver node -v | head -1)
  up_to_date "$have" "$ver" && {
    STEP_STATUS="UP-TO-DATE"
    return 0
  }
  extract_tree "https://nodejs.org/dist/latest/$file" "$OPT/node" -xJ || return 1
  local b
  for b in node npm npx; do
    [ -e "$OPT/node/bin/$b" ] && ln -sfn "$OPT/node/bin/$b" "$BIN/$b"
  done
  mark_done "$have"
}

install_uv() {
  local out
  if have_cmd uv && [ "$FORCE" -eq 0 ]; then
    if out=$(uv self update 2>&1); then
      if printf '%s' "$out" | grep -qi 'latest version'; then
        STEP_STATUS="UP-TO-DATE"
      else
        STEP_STATUS="UPDATED"
      fi
      return 0
    fi
    warn "uv self update failed, falling back to the installer"
  fi
  local had=""
  have_cmd uv && had=1
  curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || return 1
  mark_done "$had"
}

install_fzf() {
  local before="" after
  if [ -d "$HOME/.fzf/.git" ]; then
    before=$(git -C "$HOME/.fzf" rev-parse HEAD 2>/dev/null)
    git -C "$HOME/.fzf" pull --ff-only -q || return 1
    after=$(git -C "$HOME/.fzf" rev-parse HEAD 2>/dev/null)
    if [ "$before" = "$after" ] && [ "$FORCE" -eq 0 ] && have_cmd fzf; then
      STEP_STATUS="UP-TO-DATE"
      return 0
    fi
  else
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" ||
      return 1
  fi
  # .bash_aliases already sources ~/.fzf.bash, so leave ~/.bashrc alone.
  "$HOME/.fzf/install" --key-bindings --completion --no-update-rc \
    >/dev/null 2>&1 || return 1
  mark_done "$before"
}

install_tpm() {
  local dir="$HOME/.tmux/plugins/tpm" before after
  if [ -d "$dir/.git" ]; then
    before=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
    git -C "$dir" pull --ff-only -q || return 1
    after=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
    if [ "$before" = "$after" ]; then
      STEP_STATUS="UP-TO-DATE"
    else
      STEP_STATUS="UPDATED"
    fi
    return 0
  fi
  git clone -q https://github.com/tmux-plugins/tpm "$dir" || return 1
  STEP_STATUS="INSTALLED"
  detail "press prefix + I inside tmux to install the plugins"
}

install_font() {
  have_cmd fc-cache || {
    STEP_STATUS="SKIPPED"
    warn "fontconfig missing, cannot register the font"
    return 0
  }
  have_cmd xz || {
    STEP_STATUS="SKIPPED"
    warn "xz missing, cannot unpack the font archive"
    return 0
  }
  local latest have dest="$FONT_DIR/UbuntuMonoNerdFont"
  latest=$(gh_latest ryanoasis/nerd-fonts) || return 1
  have=$(stamp_get nerd-font)
  if up_to_date "$have" "$latest" && [ -d "$dest" ]; then
    STEP_STATUS="UP-TO-DATE"
    return 0
  fi
  rm -rf "$dest" && mkdir -p "$dest" || return 1
  local url="https://github.com/ryanoasis/nerd-fonts/releases/download/$latest"
  url="$url/UbuntuMono.tar.xz"
  curl -fsSL --max-time 600 "$url" | tar -xJf - -C "$dest" || return 1
  fc-cache -f "$FONT_DIR" >/dev/null 2>&1
  stamp_set nerd-font "$latest" || return 1
  mark_done "$have"
}

# ---------------------------------------------------------------------------
# Local deb extraction, used for the clipboard tools
#
# "apt-get download" needs no root: it only reads the package lists under
# /var/lib/apt/lists and fetches the .deb into the current directory.
# ---------------------------------------------------------------------------

deb_candidate_version() {
  apt-cache policy "$1" 2>/dev/null | awk '/Candidate:/ {print $2}'
}

deb_download() {
  local pkg=$1 dir=$2 uri
  (cd "$dir" && apt-get download "$pkg" >/dev/null 2>&1) && return 0
  # Fall back to the archive URL when the package lists cannot be resolved.
  uri=$(apt-get download --print-uris "$pkg" 2>/dev/null |
    awk '{print $1}' | tr -d "'" | head -1)
  [ -n "$uri" ] || return 1
  curl -fsSL --max-time 300 -o "$dir/${pkg}.deb" "$uri"
}

# Extract a package plus, if the binary still has unresolved libraries, its
# dependencies, and expose the requested binaries in ~/.local/bin.
deb_local_install() {
  local pkg=$1
  shift
  local dest="$OPT/$pkg" dir="$WORK/deb-$pkg" deb b target
  rm -rf "$dir" && mkdir -p "$dir" || return 1
  deb_download "$pkg" "$dir" || return 1
  deb=$(find "$dir" -maxdepth 1 -name '*.deb' | head -1)
  [ -n "$deb" ] || return 1
  rm -rf "$dest" && mkdir -p "$dest" || return 1
  dpkg-deb -x "$deb" "$dest" || return 1

  local libdir="$dest/usr/lib/x86_64-linux-gnu" needs_libs=0
  for b in "$@"; do
    target="$dest/usr/bin/$b"
    [ -x "$target" ] || {
      err "$b not found in $pkg"
      return 1
    }
    if ldd "$target" 2>/dev/null | grep -q 'not found'; then
      needs_libs=1
    fi
  done

  if [ "$needs_libs" -eq 1 ]; then
    local dep
    for dep in $(apt-cache depends "$pkg" 2>/dev/null |
      awk '/Depends:/ {print $2}' | grep -v '^libc6$'); do
      deb_download "$dep" "$dir" || continue
      deb=$(find "$dir" -maxdepth 1 -name "${dep}_*.deb" | head -1)
      [ -n "$deb" ] && dpkg-deb -x "$deb" "$dest"
    done
  fi

  for b in "$@"; do
    target="$dest/usr/bin/$b"
    if [ "$needs_libs" -eq 1 ]; then
      # A wrapper is needed because the loader has no other way to find the
      # libraries we just unpacked into $HOME.
      cat >"$BIN/$b" <<EOF
#!/bin/sh
# Generated by setup.sh; wraps the locally extracted $pkg.
LD_LIBRARY_PATH="$libdir\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH
exec "$target" "\$@"
EOF
      chmod 755 "$BIN/$b" || return 1
    else
      ln -sfn "$target" "$BIN/$b" || return 1
    fi
  done
}

clipboard_step() {
  local pkg=$1
  shift
  local primary=$1
  if ! have_cmd apt-get || ! have_cmd dpkg-deb; then
    STEP_STATUS="SKIPPED"
    warn "apt-get/dpkg-deb missing, cannot unpack $pkg locally"
    return 0
  fi
  local latest have
  latest=$(deb_candidate_version "$pkg")
  have=$(stamp_get "$pkg")
  if up_to_date "$have" "$latest" && have_cmd "$primary"; then
    STEP_STATUS="UP-TO-DATE"
    return 0
  fi
  deb_local_install "$pkg" "$@" || return 1
  stamp_set "$pkg" "$latest"
  mark_done "$have"
}

install_xclip() {
  # Any working clipboard tool already on PATH is enough; a second copy in
  # ~/.local buys nothing. --force installs the local copy anyway.
  if [ "$FORCE" -eq 0 ] &&
    { have_cmd xclip || have_cmd wl-copy || have_cmd xsel; }; then
    STEP_STATUS="PRESENT"
    return 0
  fi
  clipboard_step xclip xclip
}

install_wl_clipboard() {
  if [ -z "${WAYLAND_DISPLAY:-}" ]; then
    STEP_STATUS="SKIPPED"
    return 0
  fi
  if [ "$FORCE" -eq 0 ] && have_cmd wl-copy; then
    STEP_STATUS="PRESENT"
    return 0
  fi
  clipboard_step wl-clipboard wl-copy wl-paste
}

# These track git master and carry no version, so they are refreshed each run.
install_git_helpers() {
  local base="https://raw.githubusercontent.com/git/git/master/contrib/completion"
  curl -fsSL "$base/git-completion.bash" -o "$HOME/.git-completion.bash" ||
    return 1
  curl -fsSL "$base/git-prompt.sh" -o "$HOME/.git-prompt.sh" || return 1
  STEP_STATUS="REFRESHED"
}

# ---------------------------------------------------------------------------
# Dotfile symlinks
# ---------------------------------------------------------------------------

link() {
  local src=$1 dst=$2
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    return 0
  fi
  ln -s "$src" "$dst" && detail "linked $dst" && LINKED=$((LINKED + 1))
}

install_dotlinks() {
  mkdir -p "$HOME/.config" "$HOME/.ssh" || return 1
  chmod 700 "$HOME/.ssh"
  local LINKED=0
  link "$DOTFILES/.bash_profile" "$HOME/.bash_profile"
  link "$DOTFILES/.bash_aliases" "$HOME/.bash_aliases"
  link "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
  link "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
  link "$DOTFILES/.vimrc" "$HOME/.vimrc"
  link "$DOTFILES/.inputrc" "$HOME/.inputrc"
  link "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
  link "$DOTFILES/nvim" "$HOME/.config/nvim"
  link "$DOTFILES/config" "$HOME/.ssh/config"
  if [ ! -e "$HOME/.bashrc" ] && [ -f /etc/skel/.bashrc ]; then
    cp /etc/skel/.bashrc "$HOME/.bashrc" && detail "copied default ~/.bashrc"
    LINKED=$((LINKED + 1))
  fi
  if [ "$LINKED" -eq 0 ]; then
    STEP_STATUS="UP-TO-DATE"
  else
    STEP_STATUS="OK"
  fi
}

# GNOME "Screen Blank: Never" plus no idle lock. These are plain gsettings keys
# so no sudo is involved, which is why they can live here rather than in
# gnome_setup.sh. Skipped on WSL, where Windows owns the lock screen.
install_screen_blank() {
  if is_wsl; then
    STEP_STATUS="SKIPPED"
    return 0
  fi
  if ! have_cmd gsettings; then
    STEP_STATUS="SKIPPED"
    return 0
  fi

  # idle-delay is a uint32 and "gsettings get" prints it as "uint32 0", so the
  # wanted value has to be spelled the same way or this could never compare
  # equal and the step would report a change on every run.
  local -a wanted=(
    "org.gnome.desktop.session|idle-delay|uint32 0"
    "org.gnome.desktop.screensaver|lock-enabled|false"
    "org.gnome.desktop.screensaver|idle-activation-enabled|false"
  )

  local schemas entry schema key want current applied=0 absent=0 rest
  schemas=$(gsettings list-schemas 2>/dev/null)
  for entry in "${wanted[@]}"; do
    schema=${entry%%|*}
    rest=${entry#*|}
    key=${rest%%|*}
    want=${rest#*|}
    if ! printf '%s\n' "$schemas" | grep -qx "$schema"; then
      absent=$((absent + 1))
      continue
    fi
    if ! current=$(gsettings get "$schema" "$key" 2>/dev/null); then
      absent=$((absent + 1))
      continue
    fi
    [ "$current" = "$want" ] && continue
    gsettings set "$schema" "$key" "$want" || return 1
    applied=$((applied + 1))
  done

  if [ "$absent" -eq "${#wanted[@]}" ]; then
    STEP_STATUS="SKIPPED"
    warn "GNOME screensaver schemas not installed"
  elif [ "$applied" -gt 0 ]; then
    STEP_STATUS="CONFIGURED"
    detail "screen blank set to never, idle lock disabled"
  else
    STEP_STATUS="UP-TO-DATE"
  fi
}

# Terminal colours and font live in their own script, because Windows Terminal
# and GNOME Terminal have nothing in common. Its exit codes are mapped onto the
# step summary here: 3 means nothing needed changing, 4 means no supported
# terminal exists on this machine.
install_terminal() {
  local script="$DOTFILES/terminal_setup.sh" rc
  if [ ! -x "$script" ]; then
    STEP_STATUS="SKIPPED"
    warn "terminal_setup.sh missing or not executable"
    return 0
  fi
  "$script" --quiet
  rc=$?
  case $rc in
  0) STEP_STATUS="CONFIGURED" ;;
  3) STEP_STATUS="UP-TO-DATE" ;;
  4) STEP_STATUS="SKIPPED" ;;
  *) return 1 ;;
  esac
}

# ---------------------------------------------------------------------------

main() {
  preflight
  WORK="$(mktemp -d)" || exit 1
  trap 'rm -rf "$WORK"' EXIT
  mkdir -p "$BIN" "$OPT" "$FONT_DIR" "$STAMP_DIR" || exit 1

  step starship install_starship
  step nvim install_nvim
  step lazygit install_lazygit
  step ripgrep install_ripgrep
  step bat install_bat
  step fd install_fd
  step node install_node
  step uv install_uv
  step fzf install_fzf
  step tpm install_tpm
  step font install_font
  step xclip install_xclip
  step wl-clipboard install_wl_clipboard
  step git-helpers install_git_helpers
  step dotlinks install_dotlinks
  step terminal install_terminal
  step screen-blank install_screen_blank

  summarize
}

main
