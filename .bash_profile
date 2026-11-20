export TZ=America/Los_Angeles
export LC_TIME=en_US.UTF-8
# Pixi, where a project's README installed it (setup.sh does not), for SSH
# logins, which environment.d/99-pixi.conf does not reach.
if [ -d "${HOME}/.pixi/bin" ]; then
  case ":${PATH}:" in
    *":${HOME}/.pixi/bin:"*) ;;
    *) export PATH="${HOME}/.pixi/bin:${PATH}" ;;
  esac
fi
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
# Non-interactive login shells (Cursor Remote SSH, ssh bash -lc) return from
# ~/.bashrc before aliases run, so DISPLAY has to be set here as well.
if [ -f ~/.display.sh ]; then
  . ~/.display.sh
fi
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
