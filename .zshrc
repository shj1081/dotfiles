# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh  

# ========================= custom =========================
# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh


# brew configuration
export PATH=/opt/homebrew/bin:$PATH
export PATH=/opt/homebrew/sbin:$PATH


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

# export custom script path
export PATH="$HOME/dotfiles/scripts:$PATH"

# locale configuration during ssh login
# export LANG=ko_KR.UTF-8
# export LC_ALL=ko_KR.UTF-8

# bat configuration
export BAT_THEME="ansi"

# go configuration
export GOROOT="/opt/homebrew/opt/go@1.24/libexec"
export PATH="/opt/homebrew/opt/go@1.24/bin:$PATH"
export PATH=$PATH:$HOME/go/bin

# starship
eval "$(starship init zsh)"

# the fuck
eval $(thefuck --alias)


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

# ========================= alias =========================
# git
alias g='git'
alias gb='git branch'
alias gba='git branch --all'  
alias gbd='git branch --delete'
alias gp='git push'
alias gl='git pull'
alias gc='git clone'
alias gch='git checkout $(git branch | fzf)'

# system
alias c='clear'
alias e='exit'
alias ag="alias | grep "

# ssh config
alias sshconfig='bat ~/.ssh/config'

# lsd
alias ls='lsd --icon never'
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

# brew
alias bu='brew upgrade'
alias bs='brew services'
alias bl='brew list'
alias bi='brew install'
alias bui='brew uninstall'


# python
alias py='python3'

# cursor to code
# alias code='cursor'

# docker
alias d='docker'
alias dstop='docker stop'
alias dstart='docker start -i'
alias dps='docker ps -a'
alias da='docker attach'

# docker mysql
alias dmysql='docker exec -it mysql-container mysql -u root -p'

# docker postgres
alias dpsql='docker exec -it postgres-container psql -U root'



# kubectl completion
source <(kubectl completion zsh)

# kubectl alias
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kx='kubectl exec -it'

# Added by Windsurf
export PATH="/Users/hyzoon/.codeium/windsurf/bin:$PATH"
