#!/bin/bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
curl -sS https://starship.rs/install.sh | sh
sudo apt install fonts-powerline

ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.vimrc ~/.vimrc
mkdir -p ~/.config && ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
