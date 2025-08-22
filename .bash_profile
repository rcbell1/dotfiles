if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
