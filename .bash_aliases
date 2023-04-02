[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# enable tab autocompletions for git things like branches
if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi
# test -f ~/.git-completion.bash && . $_  # same as above but one line

# enable custom prompt with git info
if [ -f ~/.git-prompt.sh ]; then
    . ~/.git-prompt.sh
fi

export BAT_THEME="Dracula"
export PATH=$PATH:/home/rbell/.local/bin
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,output,node_modules,*.swp,dist,*.coffee}/*" 2> /dev/null'
export FZF_ALT_C_COMMAND='bfs -type d -nohidden -exclude -name "Music" -exclude -name "Drive"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--bind J:down,K:up --reverse --ansi --multi --preview "bat --style=numbers --color=always --line-range :500 {}"'

# export PYTHONPATH="${PYTHONPATH}:/home/rbell/miniconda3/lib/python3.8/site-packages/"
# export PYTHONPATH=/usr/local/lib/python3/dist-packages

# this is useful when using virtualenv for python
export WORKON_HOME=~/virtualenvs
function workon {
  source "$WORKON_HOME/$1/bin/activate"
}

#custom command prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWCOLORHINTS=1
# no background colors in prompt
# export PROMPT_COMMAND='__git_ps1 "\[\e[01;36m\][\$(date +%T\ %D\ %A)] \[\e[01;32m\]\u@\h:\[\e[01;34m\]\w" "\[\e[00m\]\$ " "\[\e[00m\]\n\[\e[36m\][%s]"'
# with background colors in prompt
#export PROMPT_COMMAND='__git_ps1 "\[\e[01;42;30m\][\$(date +%T\ %D\ %A)] \[\e[01;105;97m\]\u@\h:\[\e[01;44;32m\]\w" "\[\e[00m\]\$ " "\[\e[00m\]\n\[\e[36m\][%s]"'
eval "$(starship init bash)"

# Bash aliases
alias setbuffs='sudo sysctl -w net.core.rmem_max=33554432;sudo sysctl -w net.core.wmem_max=33554432;sudo sysctl -w net.core.wmem_default=33554432;sudo sysctl -w net.core.rmem_default=33554432'
alias setethtool='sudo ethtool -G enp181s0f0 tx 4096 rx 4096;sudo ethtool -G enp181s0f1 tx 4096 rx 4096'
alias duh='du -hd 1'
# alias bat='batcat'
alias vim='nvim'
alias vi='vim' 

# Git aliases
alias glog='git log --oneline --graph --format="%C(yellow)%h %C(blue)%an %C(green)%ad %C(bold red)%d %C(reset)%s" --date=format:"%m/%d/%y %H:%M:%S"'
alias gsub='git submodule update --init --recursive'
alias gs='git status'
alias gdiff='git difftool -t vimdiff -y'
alias lg='lazygit'
alias gd='git diff'
