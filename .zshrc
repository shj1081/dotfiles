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
# export JAVA_HOME_17=$(/usr/libexec/java_home -v 17)
# export JAVA_HOME_11=$(/usr/libexec/java_home -v 11)

# setup java version
# export JAVA_HOME=$JAVA_HOME_17

# export custom script path so that we can use custom scripts in any directorys
export PATH="$HOME/dotfiles/scripts:$PATH"

# bat configuration
export BAT_THEME="ansi"

# go configuration
export GOROOT="/opt/homebrew/opt/go/libexec"
export PATH="/opt/homebrew/opt/go/bin:$PATH"
export PATH=$PATH:$HOME/go/bin

# zoxide configuration
eval "$(zoxide init zsh)"


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


# uv python
alias uvr="uv run" # run a command or script
alias py="uv run --no-project"
alias uvinit="uv init" # create a new project
alias uva="uv add" # set an alias for uv command
alias uvd="uv remove" # remove an alias
alias uvp="uv pip" # install a package


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

# Added by Windsurf
export PATH="/Users/hyzoon/.codeium/windsurf/bin:$PATH"

# mise
eval "$(mise activate zsh)"
# Added by Windsurf
export PATH="/Users/hyzoon/.codeium/windsurf/bin:$PATH"

# vpn function
function vpn() {
  local warp_status=$(warp-cli status | grep "Status update" | awk '{print $3}')

  if [[ "$warp_status" == "Connected" ]]; then
    echo "Disconnecting WARP..."
    warp-cli disconnect
  else
    echo "Connecting WARP..."
    warp-cli connect
  fi
}
