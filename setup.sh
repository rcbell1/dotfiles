#!/bin/bash

# On Windows, download UbuntoMono.zip from https://github.com/ryanoasis/nerd-fonts/releases
# Unzip the file and install it by double clicking the UbuntuMonoNerdFontMono-Regular.tff file
# Then open a window terminal and from the drop down arrow in the tabs choose
# Settings -> Defaults (Profiles section) -> Appearence -> Font Face
# Choose the 'UbuntuMono Nerd Font Mono' option. Restart the terminal

echo
echo "Updating system with apt and installing required apt packages"
sudo apt -qq update
sudo apt-get install -y -qq gnome-tweaks xclip unzip python3-venv >/dev/null
echo

# for ubuntu versions that do not have starship available in snap
if command -v lazygit >/dev/null 2>&1; then
  echo "starship already installed - Skipping"
else
  echo "Installing starship" &&
    mkdir -p ~/.local/bin &&
    curl -fsSL https://starship.rs/install.sh | sh -s -- -b ~/.local/bin
fi

# download and install nerd font, needed for glyphs used by starship
FILE=/usr/share/fonts/UbuntuMonoNerdFontMono-Regular.ttf
if [ ! -e "$FILE" ]; then
  echo "Downloading UbuntuMonoNerdFontMono-Regular.tff nerd font"
  sudo curl -fsSL https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/UbuntuMono/Regular/UbuntuMonoNerdFontMono-Regular.ttf -o "$FILE"
  fc-cache -f -v
fi

# clone the tmux plugin manager tpm, Ctrl+b Shift+i to install plugins
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# download and install latest stable neovim
if command -v nvim >/dev/null 2>&1; then
  echo "nvim already installed - Skipping"
else
  echo "Installing nvim" &&
    sudo snap install nvim --classic
fi

# Lazy git download and install
if command -v lazygit >/dev/null 2>&1; then
  echo "lazygit already installed - Skipping"
else
  LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') &&
    echo "Installing lazygit" &&
    curl -fsSLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" &&
    tar xf lazygit.tar.gz lazygit &&
    sudo install lazygit /usr/local/bin &&
    rm lazygit.tar.gz lazygit
fi

# Ripgrep download and install
if command -v rg >/dev/null 2>&1; then
  echo "ripgrep already installed - Skipping."
else
  echo "Installing ripgrep" &&
    tmp="$(mktemp)" &&
    curl -fsSLo "$tmp" https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb &&
    sudo dpkg -i "$tmp" || sudo apt-get -y -f install &&
    rm -f "$tmp"
fi

# nodejs and npm support for LSP servers and Copilot in neovim
# Be sure to type ':Copilot setup' in neovim to install the Copilot binary
if command -v node >/dev/null 2>&1; then
  echo "nodejs already installed: $(node -v) - Skipping."
else
  echo "Installing nodejs" &&
    curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash - &&
    [ -f /etc/apt/sources.list.d/nodesource.list ] && cat /etc/apt/sources.list.d/nodesource.list &&
    sudo apt-get install -y nodejs build-essential &&
    node -v
fi

# clone and install fzf
if command -v fzf >/dev/null 2>&1; then
  echo "fzf already installed - Skipping."
else
  echo "Installing fzf" &&
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &&
    ~/.fzf/install --all &&
    sudo apt -y install fd-find
fi

# install bat, the cat replacement with better options
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
  echo "bat already installed - Skipping"
else
  echo "Installing bat" &&
    tmp="$(mktemp)" &&
    curl -fsSLo "$tmp" https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb &&
    # install; if deps are missing, let apt fix them
    sudo dpkg -i "$tmp" &&
    rm -f "$tmp"
fi

# install python project manager
if command -v uv >/dev/null 2>&1; then
  echo "uv already installed - Skipping."
else
  # curl -fsSL https://install.python-poetry.org | python3 -
  echo "Installing uv" &&
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if command -v google-chrome >/dev/null 2>&1; then
  echo "google chrome already installed - Skipping."
else
  echo "Installing google chrome" &&
    tmp="$(mktemp)" &&
    wget -qO "$tmp" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
    sudo dpkg -i "$tmp" || sudo apt-get -y -f install &&
    rm -f "$tmp"
fi

# create symlinks to dotfiles if they don't already exist
[ -e ~/.git-completion.bash ] || { echo "Downloading git-completion.bash" && curl -fsSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash; }
[ -e ~/.git-prompt.sh ] || { echo "Downloading git-prompt.sh" && curl -fsSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh; }
[ -e ~/.bash_profile ] || { ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.bash_profile" ~/.bash_profile && echo "Created ~/.bash_profile symlink."; }
[ -e ~/.bash_aliases ] || { ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.bash_aliases" ~/.bash_aliases && echo "Created ~/.bash_aliases symlink."; }
[ -e ~/.gitconfig ] || { ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.gitconfig" ~/.gitconfig && echo "Created ~/.gitconfig symlink."; }
[ -e ~/.tmux.conf ] || { ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.tmux.conf" ~/.tmux.conf && echo "Created ~/.tmux.conf symlink."; }
[ -e ~/.vimrc ] || { ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.vimrc" ~/.vimrc && echo "Created ~/.vimrc symlink."; }
[ -e ~/.config/starship.toml ] || { ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/starship.toml" ~/.config/starship.toml && echo "Created ~/.config/starship.toml symlink."; }
[ -d ~/.config/nvim ] || { ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/nvim" ~/.config/nvim && echo "Created ~/.config/nvim symlink."; }
[ -e /usr/bin/bat ] || { sudo ln -s /usr/bin/batcat /usr/bin/bat && echo "Created batcat -> bat symlink."; }
[ -e ~/.ssh/config ] || { sudo ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/config" ~/.ssh/config && echo "Created ~/.ssh/config symlink."; }
[ -e ~/.bashrc ] || { cp /etc/skel/.bashrc ~/.bashrc && echo "Copied default ~/.bashrc file."; }

echo

source ~/.bashrc
