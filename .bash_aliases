#export PYTHONPATH=/usr/local/lib/python3/dist-packages
export BAT_THEME="Dracula"
export PATH=$PATH:/home/rbell/.local/bin
export PROMPT_COMMAND="echo -n \[\$(date +%H:%M:%S\ %m/%d)\]\ "

# INITIAL_QUERY=""
# RG_PREFIX="rg --line-number --color=always --smart-case "
# # RG_PREFIX="grep"
# FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
#     fzf --bind "change:reload:$RG_PREFIX {q} || true" \
#         --ansi --disabled --query "$INITIAL_QUERY" \
#         --height=50% --layout=reverse --multi --extended --no-height \
#         --preview 'bat {}'
#         # --preview 'bat --style=numbers --color=always --line-range :50 {1}'
# # FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" fzf --height=50% --preview 'cat {}'
# # FZF_DEFAULT_OPTS="--multi --height=50% --preview 'cat {}' --no-height --extended"


[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,output,node_modules,*.swp,dist,*.coffee}/*" 2> /dev/null'
export FZF_ALT_C_COMMAND='bfs -type d -nohidden -exclude -name "Music" -exclude -name "Drive"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--bind J:down,K:up --reverse --ansi --multi --preview "bat --style=numbers --color=always --line-range :500 {}"'

# Aliases
alias glog='git log --oneline --decorate --graph --all'
alias setbuffs='sudo sysctl -w net.core.rmem_max=33554432;sudo sysctl -w net.core.wmem_max=33554432;sudo sysctl -w net.core.wmem_default=33554432;sudo sysctl -w net.core.rmem_default=33554432'
alias setethtool='sudo ethtool -G enp181s0f0 tx 4096 rx 4096;sudo ethtool -G enp181s0f1 tx 4096 rx 4096'
