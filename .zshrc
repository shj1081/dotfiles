# === p10k ===
# p10k instant prompt (should be at the very top of ~/.zshrc)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# === zinit configuration ===
# ZINIT directory
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit."

# download zinit if not exists
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$ZINIT_HOME"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi 

# load zinit
source "$ZINIT_HOME/zinit.zsh"

# add powerlevel10k theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# === zinit plugins ===
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# add in snippets
zinit snippet OMZP::brew
zinit snippet OMZP::node
zinit snippet OMZP::yarn

# load completions
autoload -U compinit && compinit
zinit cdreplay -q

# HISTORY
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
HISTDUP=erase
setopt append_history
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # use LS_COLORS
zstyle ':completion:*' menu no # disable default completion menu
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath' # cd preview
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath' # zoxide preview

# === keybindings ===
# use emacs keybindings
bindkey -e

# related history search
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward 

# ===  custom config ===
# brew configuration
export PATH=/opt/homebrew/bin:$PATH
export PATH=/opt/homebrew/sbin:$PATH

# export custom script path so that we can use custom scripts in any directorys
export PATH="$HOME/dotfiles/scripts:$PATH"

# bat configuration
export BAT_THEME="ansi"

# go configuration
export GOROOT="/opt/homebrew/opt/go/libexec"
export PATH="/opt/homebrew/opt/go/bin:$PATH"
export PATH=$PATH:$HOME/go/bin

# zoxide configuration
eval "$(zoxide init --cmd cd zsh)"

# fzf configuration
eval "$(fzf --zsh)" # shell integration

# mise configuration
eval "$(mise activate zsh)"

# === alias ===
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
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# Added by Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

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
