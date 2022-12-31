#!/bin/bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh

ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
#ln -s .tmux ../.tmux
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
#ln -s .vim ../.vim
ln -s ~/dotfiles/.vimrc ~/.vimrc
