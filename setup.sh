#!/bin/bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
[ -f ~/.config/starship.toml ] || curl -sS https://starship.rs/install.sh | sh

# download and install nerd font, needed for glyphs used by starship
FILE=/usr/share/fonts/'Ubuntu Mono Nerd Font Complete Mono.ttf'
if [ ! -f "$FILE" ]; then
sudo curl -L https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf  -o "$FILE"
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
curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
cat /etc/apt/sources.list.d/nodesource.list
sudo apt -y install nodejs
sudo apt -y install build-essential
node -v

[ -f ~/.bash_profile ] || ln -s ~/dotfiles/.bash_profile ~/.bash_profile
[ -f ~/.bash_aliases ] || ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases
[ -f ~/.gitconfig ] || ln -s ~/dotfiles/.gitconfig ~/.gitconfig
[ -f ~/.tmux.conf ] || ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
[ -f ~/.vimrc ] || ln -s ~/dotfiles/.vimrc ~/.vimrc
mkdir -p ~/.config && [ -f ~/.config/starship.toml ] || ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
[ -d ~/.config/nvim ] || ln -s ~/dotfiles/nvim ~/.config/nvim
[ -f /usr/bin/bat ] || sudo ln -s /usr/bin/batcat /usr/bin/bat

