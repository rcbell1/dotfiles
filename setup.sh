#!/bin/bash
sudo apt update
sudo apt -y install gnome-tweaks
sudo apt -y install xclip
sudo apt -y install unzip        # needed for mason nvim installs like clangd
sudo apt -y install python3-venv # needed for mason nvim installs like ruff
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh

# for ubuntu versions that do not have starship available in snap
[ -f ~/.config/starship.toml ] || curl -sS https://starship.rs/install.sh | sh
# for ubuntu version that have starship in snap
# sudo snap install starship --edge

# download and install nerd font, needed for glyphs used by starship
FILE=/usr/share/fonts/UbuntuMonoNerdFontMono-Regular.ttf
if [ ! -f "$FILE" ]; then
  # sudo curl -L https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf  -o "$FILE"
  sudo curl -L https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/UbuntuMono/Regular/UbuntuMonoNerdFontMono-Regular.ttf -o "$FILE"
  fc-cache -f -v
fi

# clone the tmux plugin manager tpm, Ctrl+b Shift+i to install plugins
[ ! -d ~/.tmux/plugins/tpm ] && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# download and install latest stable neovim
sudo snap install nvim --classic

# Lazy git download and install
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit

# Ripgrep download and install
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
sudo dpkg -i ripgrep_13.0.0_amd64.deb
rm ripgrep_13.0.0_amd64.deb

# nodejs and npm support for LSP servers and Copilot in neovim
# Be sure to type ':Copilot setup' in neovim to install the Copilot binary
curl -sL https://deb.nodesource.com/setup_20.x | sudo bash -
cat /etc/apt/sources.list.d/nodesource.list
sudo apt -y install nodejs
sudo apt -y install build-essential
node -v

# clone and install fzf
[ -f ~/.fzf ] || git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
sudo apt -y install fd-find

# install bat, the cat replacement with better options
curl -L https://github.com/sharkdp/bat/releases/download/v0.22.1/bat-musl_0.22.1_amd64.deb -o bat.deb
sudo dpkg -i bat.deb
rm bat.deb

# install python poetry
curl -sSL https://install.python-poetry.org | python3 -

# install google chrome on ubuntu
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i ./google-chrome*.deb
sudo apt-get -y install -f
rm google-chrome*.deb

# create symlinks to dotfiles if they don't already exist
[ -f ~/.bash_profile ] || ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.bash_profile" ~/.bash_profile
[ -f ~/.clang-format ] || ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.clang-format" ~/.clang-format
[ -f ~/.bash_aliases ] || ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.bash_aliases" ~/.bash_aliases
[ -f ~/.gitconfig ] || ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.gitconfig" ~/.gitconfig
[ -f ~/.tmux.conf ] || ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.tmux.conf" ~/.tmux.conf
[ -f ~/.vimrc ] || ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.vimrc" ~/.vimrc
mkdir -p ~/.config && [ -f ~/.config/starship.toml ] || ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/starship.toml" ~/.config/starship.toml
[ -d ~/.config/nvim ] || ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/nvim" ~/.config/nvim
[ -f /usr/bin/bat ] || sudo ln -s /usr/bin/batcat /usr/bin/bat
[ -f ~/.ssh/config ] || sudo ln -s "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/config" ~/.ssh/config
[ -f ~/.bashrc ] || cp /etc/skel/.bashrc ~/.bashrc

source ~/.bashrc
