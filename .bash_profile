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
