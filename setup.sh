#!/bin/bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
curl -sS https://starship.rs/install.sh | sh

# download and install nerd font, needed for glyphs used by starship
curl https://github.com/ryanoasis/nerd-fonts/blob/5c5c51e7b18eb080f1fa24df9d164a4b6ff62a6c/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.ttf -O
sudo mv Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.ttf /usr/share/fonts
fc-cache -f -v

# clone the tmux plugin manager tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.vimrc ~/.vimrc
mkdir -p ~/.config && ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
