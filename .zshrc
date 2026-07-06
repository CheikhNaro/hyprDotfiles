# ─────────────────────────────────────────────────────────────
# 0. FASTFETCH
# ─────────────────────────────────────────────────────────────
[[ -o interactive ]] && "$HOME/.config/fastfetch/launch.sh"

# ─────────────────────────────────────────────────────────────
# 1. HISTORIQUE
# ─────────────────────────────────────────────────────────────
#HISTFILE=~/.zsh_history
#HISTSIZE=500000
#SAVEHIST=500000

# ─────────────────────────────────────────────────────────────
# 2. PATHS ET ENVIRONNEMENT
# ─────────────────────────────────────────────────────────────
typeset -U path PATH
path=(
  $HOME/.config/herd-lite/bin
  $HOME/.composer/vendor/bin
  $HOME/.cargo/bin
  $HOME/.local/bin
  $HOME/.local/share/fnm
  $HOME/.opencode/bin
  $path
)
export PATH

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"

# ─────────────────────────────────────────────────────────────
# 3. ZINIT
# ─────────────────────────────────────────────────────────────
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33}Installing ZINIT…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# compinit — une fois par jour, silencieux par défaut
autoload -Uz compinit
() {
  local zcd="${ZDOTDIR:-$HOME}/.zcompdump"
  local zcdc="$zcd.zwc"
  if [[ -f "$zcd"(#qN.mh+24) || ! -f "$zcd" ]]; then
    compinit -d "$zcd"
    { zcompile "$zcd" } &!
  else
    compinit -C -d "$zcd"
  fi
}

zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:' fzf-preview 'ls $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls $realpath'

# ─────────────────────────────────────────────────────────────
# 4. FNM — lazy load
# ─────────────────────────────────────────────────────────────
if [[ -x "$HOME/.local/share/fnm/fnm" ]]; then
  _fnm_init() {
    unfunction _fnm_init node npm npx pnpm yarn 2>/dev/null
    eval "$(fnm env --use-on-cd --shell zsh)"
  }
  for _cmd in node npm npx pnpm yarn; do
    eval "function $_cmd() { _fnm_init; $_cmd \"\$@\"; }"
  done
fi

# ─────────────────────────────────────────────────────────────
# 5. PLUGINS — chargement différé (wait lucid)
# ─────────────────────────────────────────────────────────────
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions

# syntax-highlighting chargé après le premier prompt (non bloquant)
zinit wait lucid light-mode for \
zsh-users/zsh-syntax-highlighting

# ─────────────────────────────────────────────────────────────
# 6. OUTILS EXTERNES
# ─────────────────────────────────────────────────────────────
() {
  local _zoxide_cache="${XDG_CACHE_HOME}/zoxide-init.zsh"
  local _atuin_cache="${XDG_CACHE_HOME}/atuin-init.zsh"
  local _starship_cache="${XDG_CACHE_HOME}/starship-init.zsh"

  # Starship — synchrone mais mis en cache
  if [[ ! -f "$_starship_cache" || "$_starship_cache" -ot "$(whence -p starship)" ]]; then
    starship init zsh >| "$_starship_cache"
  fi
  source "$_starship_cache"

  # Zoxide
  if [[ ! -f "$_zoxide_cache" || "$_zoxide_cache" -ot "$(whence -p zoxide)" ]]; then
    zoxide init zsh >| "$_zoxide_cache"
  fi
  source "$_zoxide_cache"

  # Atuin
  if [[ ! -f "$_atuin_cache" || "$_atuin_cache" -ot "$HOME/.atuin/bin/atuin" ]]; then
    . "$HOME/.atuin/bin/env"
    atuin init zsh >| "$_atuin_cache"
  else
    . "$HOME/.atuin/bin/env"
  fi
  source "$_atuin_cache"
}

# ─────────────────────────────────────────────────────────────
# 7. BINDKEYS
# ─────────────────────────────────────────────────────────────
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^H'      backward-kill-word
bindkey '^[[3;5~' kill-word
bindkey '^[[3~'   delete-char

# ─────────────────────────────────────────────────────────────
# 8. ALIASES
# ─────────────────────────────────────────────────────────────
alias ls='lsd'
alias rmv='sudo dnf autoremove && sudo dnf clean all'
alias clr='clear && printf "\033[3J"'
alias ss='clear && printf "\033[3J" && ZSHRC_SOURCED="" source ~/.zshrc'
alias nrd='npm run dev'
alias nrb='npm run build'
alias ssn='sudo systemctl start NetworkManager'
alias ssp='sudo systemctl start postgresql'
alias wezthemes='touch /tmp/wezterm_trigger_theme_switcher'
alias wt='wezthemes'
alias mtrx='cmatrix'
alias cv='cava'
alias tty='tty-clock -c -C 6 -n -r -S'
alias xphp='/opt/lampp/bin/php'
# alias flatpak='flatpak --user'
alias pas='php artisan serve'
alias gcm='git commit -m'
alias gcb='git checkout -b'
alias ga='git add .'
alias gs='git status'
alias gp='git push'

# ─────────────────────────────────────────────────────────────
# 9. FONCTIONS
# ─────────────────────────────────────────────────────────────
ff() {
  clear && printf "\033[3J"
  "$HOME/.config/fastfetch/launch.sh"
}
fft() {
  "$HOME/.config/fastfetch/fftheme.sh" "$@"
  clear && printf "\033[3J"
  "$HOME/.config/fastfetch/launch.sh"
}
alias fastfetch='ff'
alias fastfetchTheme='fft'
