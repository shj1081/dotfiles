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


# hide user name and host name
PS1='%d $ '

# ========================= alias =========================
# git
alias g='git'
alias gp='git push'
alias gl='git pull'

# system
alias c='clear'
alias e='exit'
alias ag="alias | grep "

# lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# directory
alias ~='cd ~'
alias dot='cd ~/dotfiles && code . && c'
alias ..='cd ..'
alias ...='cd ../..'

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

# docker
alias d='docker'

# ========================= functions =========================
# move to directory and list files
function cdl() {
  cd $1 && l
}