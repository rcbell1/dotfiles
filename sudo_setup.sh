#!/usr/bin/env bash
#
# System prerequisites for setup.sh. This is the only script here that needs
# root, and it only needs to run once per machine (never, if the packages are
# already present, which is the case on a standard Ubuntu image).
#
# Everything else lives in setup.sh, which installs into ~/.local and needs no
# sudo at all. Keep it that way: do not move tools from there into this file
# just because sudo happens to be available.

set -uo pipefail

# apt-get and dpkg-deb are deliberately absent from this list: they are part of
# apt and dpkg, which must already exist for apt to install anything. They are
# verified below instead.
PKGS=(
  git         # cloning fzf, tpm and this repo
  curl        # every download in setup.sh
  tar         # unpacking release tarballs
  xz-utils    # the .tar.xz node and nerd-font archives
  fontconfig  # fc-cache, to register the nerd font
  tmux        # not practical to build without root (libevent, ncurses)
  libx11-6    # linked by the locally extracted xclip
  libxmu6     # linked by the locally extracted xclip
)

CHECK_ONLY=0

if [ -t 1 ]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
else
  C_RESET="" C_BOLD="" C_GREEN="" C_YELLOW="" C_RED=""
fi

info() { printf '%s==>%s %s\n' "$C_BOLD" "$C_RESET" "$*"; }
err() { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
die() {
  err "$*"
  exit 1
}

usage() {
  cat <<'EOF'
Usage: ./sudo_setup.sh [options]

Installs the system packages that setup.sh cannot install without root:
git, curl, tar, xz-utils, fontconfig, tmux, libx11-6, libxmu6.

Runs "sudo apt update" and then installs only the packages that are missing.
Safe to re-run.

Options:
  --check     Report which packages are installed or missing and exit.
              Needs no sudo and changes nothing.
  -h, --help  Show this help and exit

Afterwards run ./setup.sh, which needs no sudo.
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

pkg_installed() {
  [ "$(dpkg-query -W -f='${db:Status-Status}' "$1" 2>/dev/null)" = installed ]
}

# apt cannot install these; if they are absent this is not a Debian-family
# system and nothing else here applies.
for cmd in apt-get dpkg-query dpkg-deb; do
  command -v "$cmd" >/dev/null 2>&1 ||
    die "$cmd not found - this script requires a Debian-based distro such as Ubuntu"
done

declare -a MISSING=()
for pkg in "${PKGS[@]}"; do
  pkg_installed "$pkg" || MISSING+=("$pkg")
done

printf '%sPackage status%s\n' "$C_BOLD" "$C_RESET"
for pkg in "${PKGS[@]}"; do
  if pkg_installed "$pkg"; then
    printf '  %-12s %sinstalled%s\n' "$pkg" "$C_GREEN" "$C_RESET"
  else
    printf '  %-12s %smissing%s\n' "$pkg" "$C_YELLOW" "$C_RESET"
  fi
done
printf '\n'

if [ "$CHECK_ONLY" -eq 1 ]; then
  if [ ${#MISSING[@]} -eq 0 ]; then
    info "nothing to do - run ./setup.sh"
  else
    info "would install: ${MISSING[*]}"
  fi
  exit 0
fi

command -v sudo >/dev/null 2>&1 ||
  die "sudo not found - ask an administrator to install: ${MISSING[*]:-${PKGS[*]}}"

# Prompt for the password once, up front, rather than midway through.
sudo -v || die "could not obtain sudo privileges"

info "sudo apt update"
sudo apt update || die "apt update failed"

if [ ${#MISSING[@]} -eq 0 ]; then
  info "all prerequisites already installed, nothing to install"
else
  info "installing: ${MISSING[*]}"
  sudo apt-get install -y "${MISSING[@]}" || die "apt-get install failed"
fi

printf '\n%sSummary%s\n' "$C_BOLD" "$C_RESET"
FAILED=0
for pkg in "${PKGS[@]}"; do
  if pkg_installed "$pkg"; then
    printf '  %-12s %s\n' "$pkg" "OK"
  else
    printf '  %-12s %s\n' "$pkg" "FAILED"
    FAILED=1
  fi
done
printf '\n'

if [ "$FAILED" -eq 1 ]; then
  die "some packages are still missing"
fi

info "prerequisites ready - now run ./setup.sh (no sudo needed)"

# Optional extras, intentionally not installed automatically:
#   build-essential  only needed to compile native npm addons
#   xclip            setup.sh unpacks this into ~/.local so it also works on
#                    machines where you have no sudo
