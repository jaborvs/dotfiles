### Oh My Zsh Configuration ###################################################

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="minimal"

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

# --- Fix Path ---
export PATH="$HOME/.local/bin:$PATH"

# --- Infinite History ---
# Set history to 100 million lines (practically infinite)
HISTSIZE=100000000
SAVEHIST=100000000

# Don't save commands that start with a space (good for passwords/secrets)
setopt HIST_IGNORE_SPACE
