#!/usr/bin/env bash
#
# Terminal appearance: the Ubuntu dark colour scheme plus the UbuntuMono Nerd
# Font that setup.sh installs. No sudo needed.
#
# Which terminal gets configured is detected at runtime, because the two have
# nothing in common:
#
#   WSL           Windows Terminal, via its settings.json on the C: drive.
#                 The font is also registered for the Windows user, which is
#                 what the manual steps in setup.sh's header used to describe.
#   Native GNOME  GNOME Terminal, via gsettings on the default profile.
#
# setup.sh runs this as its "terminal" step, so it normally does not need to be
# invoked by hand.
#
# Exit codes (setup.sh maps these onto its step summary):
#   0  configured
#   1  error
#   3  already up to date, nothing changed
#   4  not applicable (no Windows Terminal and no GNOME Terminal here)

set -uo pipefail

FONT_FACE="UbuntuMono Nerd Font Mono"
FONT_SIZE=12
# Deliberately not plain "Ubuntu": Windows Terminal ships a built-in scheme by
# that name and renames any user scheme that shadows it to "Ubuntu (modified)",
# which would make this script rewrite settings.json on every single run.
SCHEME_NAME="Ubuntu Dark"
FONT_SRC="$HOME/.local/share/fonts/UbuntuMonoNerdFont"

# Ubuntu's terminal look: aubergine background with the Tango palette.
BG="#300A24"
FG="#FFFFFF"
CURSOR="#FFFFFF"
SELECTION="#B5D5FF"
P0="#2E3436" P1="#CC0000" P2="#4E9A06" P3="#C4A000"
P4="#3465A4" P5="#75507B" P6="#06989A" P7="#D3D7CF"
P8="#555753" P9="#EF2929" P10="#8AE234" P11="#FCE94F"
P12="#729FCF" P13="#AD7FA8" P14="#34E2E2" P15="#EEEEEC"

CHECK_ONLY=0
DO_FONT=1
QUIET=0

if [ -t 1 ]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_DIM=$'\033[2m'
else
  C_RESET="" C_BOLD="" C_YELLOW="" C_RED="" C_DIM=""
fi

info() { [ "$QUIET" -eq 1 ] || printf '%s==>%s %s\n' "$C_BOLD" "$C_RESET" "$*"; }
detail() { [ "$QUIET" -eq 1 ] || printf '    %s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }
warn() { printf '%swarning:%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err() { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }

usage() {
  cat <<'EOF'
Usage: ./terminal_setup.sh [options]

Applies the Ubuntu dark colour scheme and the UbuntuMono Nerd Font to the
terminal in use: Windows Terminal on WSL, GNOME Terminal on native Ubuntu.
Needs no sudo. Safe to re-run; nothing is written when already correct.

Options:
  --check      Report what would change and exit without writing anything
  --no-font    Skip registering the font with Windows (WSL only)
  --quiet      Only print warnings and errors
  -h, --help   Show this help and exit

On WSL the previous settings.json is copied to settings.json.bak-<timestamp>
before anything is written, and the new file is validated as JSON first.
EOF
}

while [ $# -gt 0 ]; do
  case $1 in
  --check) CHECK_ONLY=1 ;;
  --no-font) DO_FONT=0 ;;
  --quiet) QUIET=1 ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    err "Unknown option: $1"
    usage >&2
    exit 2
    ;;
  esac
  shift
done

is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] ||
    grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null
}

# ---------------------------------------------------------------------------
# Windows Terminal
# ---------------------------------------------------------------------------

# %LOCALAPPDATA% as a Linux path. cmd.exe is run from /mnt/c because it warns
# and falls back to C:\Windows when the cwd is not a Windows-visible path.
win_localappdata() {
  local raw
  raw=$(cd /mnt/c 2>/dev/null &&
    cmd.exe /c "echo %LOCALAPPDATA%" 2>/dev/null | tr -d '\r\n')
  case $raw in
  [A-Za-z]:\\*) wslpath -u "$raw" ;;
  *) return 1 ;;
  esac
}

wt_settings_files() {
  local lad=$1
  local p
  for p in \
    "$lad/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" \
    "$lad/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json" \
    "$lad/Microsoft/Windows Terminal/settings.json"; do
    [ -f "$p" ] && printf '%s\n' "$p"
  done
}

# Register the font for the Windows user. This needs no admin rights: fonts in
# %LOCALAPPDATA%\Microsoft\Windows\Fonts with an HKCU registry value are
# per-user installs. Windows Terminal picks them up after a restart.
wt_install_font() {
  local lad=$1
  local wfonts="$lad/Microsoft/Windows/Fonts" installed=0 skipped=0
  local style ttf winpath regname
  if [ ! -d "$FONT_SRC" ]; then
    warn "no fonts at $FONT_SRC; run ./setup.sh --only font first"
    return 0
  fi
  have_cmd reg.exe || {
    warn "reg.exe not found, cannot register the font with Windows"
    return 0
  }
  mkdir -p "$wfonts" || return 1
  for style in Regular Bold Italic BoldItalic; do
    ttf="UbuntuMonoNerdFontMono-$style.ttf"
    [ -f "$FONT_SRC/$ttf" ] || continue
    if [ -f "$wfonts/$ttf" ]; then
      skipped=$((skipped + 1))
      continue
    fi
    if [ "$CHECK_ONLY" -eq 1 ]; then
      detail "would install $ttf for the Windows user"
      installed=$((installed + 1))
      continue
    fi
    cp "$FONT_SRC/$ttf" "$wfonts/$ttf" || return 1
    winpath=$(wslpath -w "$wfonts/$ttf") || return 1
    if [ "$style" = Regular ]; then
      regname="$FONT_FACE (TrueType)"
    else
      regname="$FONT_FACE $style (TrueType)"
    fi
    reg.exe add 'HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts' \
      /v "$regname" /t REG_SZ /d "$winpath" /f >/dev/null 2>&1 || return 1
    installed=$((installed + 1))
  done
  if [ "$installed" -gt 0 ]; then
    detail "font: $installed installed for the Windows user, $skipped already present"
    detail "restart Windows Terminal for a newly installed font to appear"
  else
    detail "font: already installed for the Windows user"
  fi
}

wt_scheme_json() {
  jq -n \
    --arg name "$SCHEME_NAME" --arg bg "$BG" --arg fg "$FG" \
    --arg cur "$CURSOR" --arg sel "$SELECTION" \
    --arg p0 "$P0" --arg p1 "$P1" --arg p2 "$P2" --arg p3 "$P3" \
    --arg p4 "$P4" --arg p5 "$P5" --arg p6 "$P6" --arg p7 "$P7" \
    --arg p8 "$P8" --arg p9 "$P9" --arg p10 "$P10" --arg p11 "$P11" \
    --arg p12 "$P12" --arg p13 "$P13" --arg p14 "$P14" --arg p15 "$P15" \
    '{
      name: $name, background: $bg, foreground: $fg,
      cursorColor: $cur, selectionBackground: $sel,
      black: $p0, red: $p1, green: $p2, yellow: $p3,
      blue: $p4, purple: $p5, cyan: $p6, white: $p7,
      brightBlack: $p8, brightRed: $p9, brightGreen: $p10,
      brightYellow: $p11, brightBlue: $p12, brightPurple: $p13,
      brightCyan: $p14, brightWhite: $p15
    }'
}

wt_configure_file() {
  local settings=$1 scheme_json=$2
  local tmp updated

  if ! jq -e . "$settings" >/dev/null 2>&1; then
    err "$settings is not valid JSON; refusing to touch it"
    return 1
  fi

  # Only the face is set, never the size: Windows Terminal already defaults to
  # 12 and overwriting it would clobber a deliberate choice.
  # Drop our own previous entries, including any Windows Terminal renamed with
  # its "(modified)" suffix, so repeated runs cannot accumulate copies.
  tmp="$WORK/wt.json"
  jq --arg scheme "$SCHEME_NAME" --arg face "$FONT_FACE" \
    --argjson new "$scheme_json" '
      # Windows Terminal renames a shadowing scheme to "X (modified)", then
      # "X (modified 2)" and so on, so match the whole family by pattern.
      # A bare "Ubuntu" is left alone in case it is yours; only our own name
      # and the renamed variants are removed.
      "^\($scheme)$|^(\($scheme)|Ubuntu) \\(modified( [0-9]+)?\\)$" as $stale
      | .schemes = ((.schemes // [])
          | map(select((.name // "") | test($stale) | not))
          + [$new])
      | .theme = "dark"
      | .profiles = (.profiles // {})
      | .profiles.defaults = ((.profiles.defaults // {})
          | .colorScheme = $scheme
          | .font = ((.font // {}) | .face = $face))
    ' "$settings" >"$tmp" || {
    err "jq failed to rewrite $settings"
    return 1
  }

  if ! jq -e . "$tmp" >/dev/null 2>&1; then
    err "generated settings.json is not valid JSON; leaving the original alone"
    return 1
  fi

  # Canonical comparison, so re-running reports no change rather than
  # rewriting a byte-identical file.
  if [ "$(jq -S . "$settings")" = "$(jq -S . "$tmp")" ]; then
    detail "already configured: $settings"
    return 3
  fi

  if [ "$CHECK_ONLY" -eq 1 ]; then
    detail "would update $settings"
    jq -S . "$settings" >"$WORK/before.json"
    jq -S . "$tmp" >"$WORK/after.json"
    diff -u "$WORK/before.json" "$WORK/after.json" |
      grep -E '^[-+][^-+]' | sed 's/^/      /'
    return 0
  fi

  local backup
  backup="$settings.bak-$(date +%Y%m%d%H%M%S)"
  cp "$settings" "$backup" || return 1
  # Copy rather than mv: settings.json lives on DrvFs and Windows Terminal
  # watches that exact path.
  cat "$tmp" >"$settings" || {
    err "write failed; restoring from $backup"
    cp "$backup" "$settings"
    return 1
  }
  updated=1
  detail "updated $settings"
  detail "backup at $backup"
  [ -n "$updated" ] && return 0
}

configure_windows_terminal() {
  local lad files rc=4 file_rc
  have_cmd jq || {
    err "jq is required to edit Windows Terminal settings.json"
    return 1
  }
  lad=$(win_localappdata) || {
    warn "could not resolve %LOCALAPPDATA%; is WSL interop enabled?"
    return 4
  }

  mapfile -t files < <(wt_settings_files "$lad")
  if [ ${#files[@]} -eq 0 ]; then
    warn "no Windows Terminal settings.json found under $lad"
    return 4
  fi

  local scheme_json
  scheme_json=$(wt_scheme_json) || return 1

  local f
  for f in "${files[@]}"; do
    wt_configure_file "$f" "$scheme_json"
    file_rc=$?
    case $file_rc in
    0) rc=0 ;;
    3) [ "$rc" -eq 0 ] || rc=3 ;;
    *) return 1 ;;
    esac
  done

  [ "$DO_FONT" -eq 1 ] && wt_install_font "$lad"
  return "$rc"
}

# ---------------------------------------------------------------------------
# GNOME Terminal
# ---------------------------------------------------------------------------

gt_schema_present() {
  gsettings list-schemas 2>/dev/null |
    grep -qx 'org.gnome.Terminal.ProfilesList'
}

# gsettings quotes its output, and the profile id is wrapped in single quotes.
gt_unquote() { tr -d "'" <<<"$1"; }

gt_set() {
  local path=$1 key=$2 want=$3 current
  current=$(gsettings get "$path" "$key" 2>/dev/null)
  if [ "$current" = "$want" ]; then
    return 3
  fi
  if [ "$CHECK_ONLY" -eq 1 ]; then
    detail "would set $key: ${current:-<unset>} -> $want"
    return 0
  fi
  gsettings set "$path" "$key" "$want" || return 1
  detail "set $key = $want"
}

configure_gnome_terminal() {
  have_cmd gsettings || return 4
  gt_schema_present || {
    warn "GNOME Terminal schemas not installed; nothing to configure"
    return 4
  }

  local prof path rc=3 key_rc
  prof=$(gt_unquote "$(gsettings get org.gnome.Terminal.ProfilesList default)")
  [ -n "$prof" ] || {
    err "could not determine the default GNOME Terminal profile"
    return 1
  }
  path="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$prof/"
  info "GNOME Terminal profile $prof"

  local palette
  palette="['$P0', '$P1', '$P2', '$P3', '$P4', '$P5', '$P6', '$P7',"
  palette="$palette '$P8', '$P9', '$P10', '$P11', '$P12', '$P13', '$P14', '$P15']"

  local -a keys=(
    "use-system-font|false"
    "font|'$FONT_FACE $FONT_SIZE'"
    "use-theme-colors|false"
    "background-color|'$BG'"
    "foreground-color|'$FG'"
    "bold-color-same-as-fg|true"
    "cursor-colors-set|false"
    "palette|$palette"
  )
  local entry
  for entry in "${keys[@]}"; do
    gt_set "$path" "${entry%%|*}" "${entry#*|}"
    key_rc=$?
    case $key_rc in
    0) rc=0 ;;
    3) ;;
    *) return 1 ;;
    esac
  done

  # Dark window chrome for the terminal itself.
  if gsettings list-schemas 2>/dev/null |
    grep -qx 'org.gnome.Terminal.Legacy.Settings'; then
    if gt_set org.gnome.Terminal.Legacy.Settings theme-variant "'dark'"; then
      rc=0
    fi
  fi

  return "$rc"
}

# ---------------------------------------------------------------------------

main() {
  WORK="$(mktemp -d)" || exit 1
  trap 'rm -rf "$WORK"' EXIT

  local rc
  if is_wsl; then
    info "WSL detected: configuring Windows Terminal"
    configure_windows_terminal
    rc=$?
  else
    info "native Linux detected: configuring GNOME Terminal"
    configure_gnome_terminal
    rc=$?
  fi

  case $rc in
  0)
    if [ "$CHECK_ONLY" -eq 1 ]; then
      info "check only, nothing was written"
    else
      info "terminal configured: $SCHEME_NAME dark scheme, $FONT_FACE"
    fi
    ;;
  3) info "terminal already configured" ;;
  4) warn "no supported terminal found here; skipped" ;;
  esac
  return "$rc"
}

main
