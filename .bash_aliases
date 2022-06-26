#export PYTHONPATH=/usr/local/lib/python3/dist-packages
export BAT_THEME="Dracula"
export PATH=$PATH:/home/rbell/.local/bin

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
