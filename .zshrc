# ========================= custom =========================
# brew configuration
export PATH=/opt/homebrew/bin:$PATH


# java sdk path variable
# may be you need to execute following cmd to make symbolic link
# sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
# sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
export JAVA_HOME_17=$(/usr/libexec/java_home -v 17)
export JAVA_HOME_11=$(/usr/libexec/java_home -v 11)

# setup java version
export JAVA_HOME=$JAVA_HOME_17

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Initialize pyenv and virtualenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# zoxide configuration
eval "$(zoxide init zsh)"

# fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_DEFAULT_COMMAND='rg --hidden -l ""' # Include hidden files

bindkey "ç" fzf-cd-widget # Fix for ALT+C on Mac


# fh - search in your command history and execute selected command
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# prompt configuration (hide username/host, show git branch)
autoload -Uz vcs_info
precmd() { 
  vcs_info 
  }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f %F{green}${vcs_info_msg_0_}%f$ '

# ========================= alias =========================
# git
alias g='git'
alias gp='git push'
alias gl='git pull'
alias gc='git clone'
alias gch='git checkout $(git branch | fzf)'

# system
alias c='clear'
alias e='exit'
alias ag="alias | grep "

# lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -la'
alias lt='ls --tree'

# directory
alias ~='cd ~'
alias dot='cd ~/dotfiles && code . && c'
alias ..='cd ..'
alias ...='cd ../..'
alias cdg='cd ~/git'
alias cds='cd ~/scratch'
alias cdp='cd ~/gdrive/1_Project'

# inuiyeji cluster
alias sin='ssh -p 1398 s20310083@swin.skku.edu'
alias sui='ssh -p 1398 s20310083@swui.skku.edu'
alias sye='ssh -p 1398 s20310083@swye.skku.edu'
alias sji='ssh -p 1398 s20310083@swji.skku.edu'

# postgresql
alias pgstart='brew services start postgresql'
alias pgstop='brew services stop postgresql'
alias pg='psql postgres'

# brew
alias bu='brew upgrade'
alias bs='brew services'
alias bl='brew list'
alias bi='brew install'
alias bui='brew uninstall'

# pyenv
alias pyenvi='pyenv install'
alias pyenvu='pyenv uninstall'
alias pyenvv='pyenv versions'
alias pyenvg='pyenv global'
alias pyenvl='pyenv local'
alias pyenva='pyenv activate'
alias pyenvd='pyenv deactivate'

# python
alias py='python3'

# docker
alias d='docker'
alias dstop='docker stop'
alias dstart='docker start -i'
alias dps='docker ps -a'
alias da='docker attach'

# ========================= functions =========================
# move to directory and list files
function cdl() {
  cd $1 && l
}