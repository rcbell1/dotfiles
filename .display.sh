# Sourced from ~/.bash_profile (login, including Cursor/SSH) and
# ~/.bash_aliases (interactive shells). Safe to source more than once.
#
# If this user has a live VNC server, point GUI apps at that display.
# Otherwise keep the historical default DISPLAY=:0 (WSLg, local console),
# including when VNC is not installed or is not currently running.

[ -n "${BASH_VERSION:-}" ] || return 0

_dotfiles_vnc_display() {
  local args token dpy=""
  while IFS= read -r args; do
    case $args in
    *Xtigervnc* | *Xtightvnc* | *Xvnc\ * | */Xvnc\ *)
      for token in $args; do
        case $token in
        :[0-9] | :[0-9][0-9] | :[0-9][0-9][0-9])
          dpy=$token
          ;;
        esac
      done
      ;;
    esac
  done < <(ps -u "$(id -un)" -o args= 2>/dev/null)
  if [ -n "$dpy" ]; then
    printf '%s\n' "$dpy"
    return 0
  fi
  return 1
}

if _dpy=$(_dotfiles_vnc_display); then
  export DISPLAY=$_dpy
  if [ -z "${XAUTHORITY:-}" ] && [ -f "$HOME/.Xauthority" ]; then
    export XAUTHORITY="$HOME/.Xauthority"
  fi
else
  # Same default as before VNC detection existed. Do not require VNC.
  export LIBGL_ALWAYS_INDIRECT=1
  export DISPLAY=:0
fi
unset _dpy
unset -f _dotfiles_vnc_display

# Session ssh-agent for Ubuntu GNOME, VNC, WSL, and login shells (Cursor).
# Prefer the systemd user unit when it is enabled so GUI apps and shells
# share $XDG_RUNTIME_DIR/openssh_agent. Otherwise reuse or start the per-boot
# agent in ~/.ssh/agent.env (WSL without systemd --user, or forwarded SOCK).
_dotfiles_ssh_agent() {
  local sock="" st=0 envfile="$HOME/.ssh/agent.env"
  [ -n "${XDG_RUNTIME_DIR:-}" ] && sock="${XDG_RUNTIME_DIR}/openssh_agent"

  if command -v systemctl >/dev/null 2>&1 &&
    systemctl --user is-enabled ssh-agent.service >/dev/null 2>&1; then
    [ -n "$sock" ] && export SSH_AUTH_SOCK="$sock"
    return 0
  fi
  if [ -n "$sock" ] && [ -S "$sock" ]; then
    export SSH_AUTH_SOCK="$sock"
    return 0
  fi
  if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
    return 0
  fi

  if [ -f "$envfile" ]; then
    # shellcheck disable=SC1090
    . "$envfile" >/dev/null
  fi
  if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
    ssh-add -l >/dev/null 2>&1 && return 0
    ssh-add -l >/dev/null 2>&1 || st=$?
    [ "$st" -eq 1 ] && return 0
  fi
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  (umask 077 && ssh-agent -s >"$envfile")
  # shellcheck disable=SC1090
  . "$envfile" >/dev/null
}
_dotfiles_ssh_agent
unset -f _dotfiles_ssh_agent
