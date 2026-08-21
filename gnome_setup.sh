#!/usr/bin/env bash
#
# GNOME desktop tweaks for a non-WSL Ubuntu machine. These are the settings
# gnome-tweaks exposes through its GUI, applied directly to the same gsettings
# keys it writes, so neither sudo nor the gnome-tweaks package is required.
#
# Terminal colours and the terminal font are NOT here: those live in
# terminal_setup.sh, which setup.sh runs as its "terminal" step and which knows
# how to configure GNOME Terminal as well as Windows Terminal.
#
# Refuses to run under WSL, where there is no GNOME session to configure.

set -uo pipefail

FONT_FACE="UbuntuMono Nerd Font Mono"
FONT_SIZE=12

CHECK_ONLY=0
CHANGED=0
FAILED=0
SKIPPED=0

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

info() { printf '%s==>%s %s\n' "$C_BOLD" "$C_RESET" "$*"; }
warn() { printf '%swarning:%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err() { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }

usage() {
  cat <<'EOF'
Usage: ./gnome_setup.sh [options]

Applies GNOME desktop tweaks on a native (non-WSL) Ubuntu machine:

  Appearance   dark theme (Yaru-dark plus prefer-dark), monospace font set to
               UbuntuMono Nerd Font Mono
  Windows      minimize and maximize buttons in the titlebar, new windows
               centred, workspaces spanning all displays
  Touchpad     tap to click, natural scrolling
  Top bar      battery percentage, weekday in the clock

Needs no sudo, and no gnome-tweaks package: these are the same gsettings keys
that the gnome-tweaks GUI writes. Safe to re-run.

Terminal colours and font are handled by ./terminal_setup.sh instead.

Options:
  --check     Report what would change and exit without writing anything
  -h, --help  Show this help and exit
EOF
}

while [ $# -gt 0 ]; do
  case $1 in
  --check) CHECK_ONLY=1 ;;
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

schema_present() {
  gsettings list-schemas 2>/dev/null | grep -qx "$1"
}

# Only writes when the current value differs, so a re-run is silent and the
# summary distinguishes "changed" from "already correct".
set_key() {
  local schema=$1 key=$2 want=$3 current
  if ! schema_present "$schema"; then
    printf '  %-46s %sskipped (no schema)%s\n' "$schema $key" "$C_DIM" "$C_RESET"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi
  if ! current=$(gsettings get "$schema" "$key" 2>/dev/null); then
    printf '  %-46s %sskipped (no such key)%s\n' "$schema $key" "$C_DIM" "$C_RESET"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi
  if [ "$current" = "$want" ]; then
    printf '  %-46s %sok%s\n' "$key" "$C_DIM" "$C_RESET"
    return 0
  fi
  if [ "$CHECK_ONLY" -eq 1 ]; then
    printf '  %-46s %s%s -> %s%s\n' "$key" "$C_YELLOW" "$current" "$want" "$C_RESET"
    CHANGED=$((CHANGED + 1))
    return 0
  fi
  if gsettings set "$schema" "$key" "$want" 2>/dev/null; then
    printf '  %-46s %s%s -> %s%s\n' "$key" "$C_GREEN" "$current" "$want" "$C_RESET"
    CHANGED=$((CHANGED + 1))
  else
    printf '  %-46s %sfailed%s\n' "$key" "$C_RED" "$C_RESET"
    FAILED=$((FAILED + 1))
  fi
}

if is_wsl; then
  err "this is a WSL machine; there is no GNOME session to configure"
  err "run ./setup.sh (and ./terminal_setup.sh for Windows Terminal) instead"
  exit 4
fi

if ! command -v gsettings >/dev/null 2>&1; then
  err "gsettings not found; this script needs a GNOME desktop"
  exit 4
fi

if [ -z "${XDG_CURRENT_DESKTOP:-}" ]; then
  warn "XDG_CURRENT_DESKTOP is unset; run this from inside a GNOME session"
fi

[ "$CHECK_ONLY" -eq 1 ] && info "check only, nothing will be written"

info "Appearance"
set_key org.gnome.desktop.interface color-scheme "'prefer-dark'"
set_key org.gnome.desktop.interface gtk-theme "'Yaru-dark'"
set_key org.gnome.desktop.interface monospace-font-name \
  "'$FONT_FACE $FONT_SIZE'"

info "Windows"
set_key org.gnome.desktop.wm.preferences button-layout \
  "'appmenu:minimize,maximize,close'"
set_key org.gnome.mutter center-new-windows true
# gnome-tweaks calls this "Workspaces span displays"; the key is inverted.
set_key org.gnome.mutter workspaces-only-on-primary false

info "Touchpad"
set_key org.gnome.desktop.peripherals.touchpad tap-to-click true
set_key org.gnome.desktop.peripherals.touchpad natural-scroll true

info "Top bar"
set_key org.gnome.desktop.interface show-battery-percentage true
set_key org.gnome.desktop.interface clock-show-weekday true

printf '\n%sSummary%s\n' "$C_BOLD" "$C_RESET"
if [ "$CHECK_ONLY" -eq 1 ]; then
  printf '  %s setting(s) would change, %s skipped\n' "$CHANGED" "$SKIPPED"
else
  printf '  %s changed, %s skipped, %s failed\n' "$CHANGED" "$SKIPPED" "$FAILED"
fi
printf '\n'

if [ "$FAILED" -gt 0 ]; then
  err "some settings could not be applied"
  exit 1
fi

info "terminal colours and font: run ./terminal_setup.sh"
[ "$CHANGED" -eq 0 ] && info "everything was already configured"
exit 0
