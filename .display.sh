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
