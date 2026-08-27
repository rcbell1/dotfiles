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

# ssh-agent: start one agent per boot and reuse it from every shell, so the
# "AddKeysToAgent yes" in ~/.ssh/config only prompts for a key passphrase once.
# The agent details are cached in a file because each shell is a separate
# process and would otherwise have no way to find an already running agent.
# Note the agent dies on reboot (or `wsl --shutdown`), so the passphrase is
# needed once per boot.
SSH_AGENT_ENV="$HOME/.ssh/agent.env"

ssh_agent_start() {
	(umask 077 && ssh-agent -s >"$SSH_AGENT_ENV")
	. "$SSH_AGENT_ENV" >/dev/null
}

if [ -z "${SSH_AUTH_SOCK:-}" ] && [ -f "$SSH_AGENT_ENV" ]; then
	. "$SSH_AGENT_ENV" >/dev/null
fi

# ssh-add -l exits 0 with keys loaded, 1 for an empty agent, 2 when no agent
# can be reached. Only the last case needs a new agent started.
ssh_agent_state=0
ssh-add -l >/dev/null 2>&1 || ssh_agent_state=$?
if [ "$ssh_agent_state" -eq 2 ]; then
	ssh_agent_start
fi
unset ssh_agent_state

export BAT_THEME="Dracula"
# Prepend, so the tools setup.sh installs locally take precedence over older
# system-wide copies in /usr/bin, /usr/local/bin and /snap/bin.
export PATH="$HOME/.local/bin:$PATH"
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
eval "$(starship init bash)"

# DISPLAY / XAUTHORITY: live VNC session, else WSLg :0. See ~/.display.sh.
if [ -f ~/.display.sh ]; then
	. ~/.display.sh
fi

# Bash aliases
alias setbuffs='sudo sysctl -w net.core.rmem_max=33554432;sudo sysctl -w net.core.wmem_max=33554432;sudo sysctl -w net.core.wmem_default=33554432;sudo sysctl -w net.core.rmem_default=33554432'
alias setethtool='sudo ethtool -G enp181s0f0 tx 4096 rx 4096;sudo ethtool -G enp181s0f1 tx 4096 rx 4096'
alias duh='du -hd 1'
alias vim='nvim'
alias vi='vim'
alias cat='bat'

# Git aliases
alias glog='git log --oneline --graph --format="%C(yellow)%h %C(blue)%an %C(green)%ad %C(bold red)%d %C(reset)%s" --date=format:"%m/%d/%y %H:%M:%S"'
alias gsub='git submodule update --init --recursive'
alias gs='git status'
alias gdiff='git difftool -t vimdiff -y'
alias lg='lazygit'
alias gd='git diff'
