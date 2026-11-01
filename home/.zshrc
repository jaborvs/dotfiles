### Oh My Zsh Configuration ###################################################

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="minimal"

# Stop Oh My Zsh from setting terminal title (user@host: path is too long)
DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load?
plugins=(
  git
  kubectl
  zoxide
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

### User Configuration ########################################################

# --- Fix SSH terminal issues (remotes lack the foot terminfo) ---
alias ssh='TERM=xterm-256color ssh'

# --- Fix Path ---
export PATH="$HOME/.local/bin:$PATH"

# --- Disable bracketed paste confirmation ---
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# --- Infinite History ---
# Set history to 100 million lines (practically infinite)
HISTSIZE=100000000
SAVEHIST=100000000

# Don't save commands that start with a space (good for passwords/secrets)
setopt HIST_IGNORE_SPACE

# --- Editor ---
export EDITOR=nvim
export SYSTEMD_EDITOR=vim
export VIRTUAL_ENV_DISABLE_PROMPT=1

# --- Load custom aliases (must be after oh-my-zsh to override) ---
source ~/zsh_aliases.zsh
. "$HOME/.local/share/../bin/env"
export PATH="$HOME/.local/bin:$PATH"

# --- omp a traves de Dalinar (proxy) ---
# ~/bin/omp es un wrapper que fuerza el trafico de omp por Dalinar.
# Debe ir el ultimo para ganar la resolucion de PATH sobre ~/.local/bin/omp
# (el binario real, autoactualizable, que no se toca).
export PATH="$HOME/bin:$PATH"
