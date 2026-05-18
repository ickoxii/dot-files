# Anything for interactive shells.
# Plugins, keybinds, prompts, etc.
# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout

if [[ -n "$container" ]] || [[ -n "$DOCKER_CONTAINER" ]] || [[ "$ZSH_MINIMAL" == "1" ]]; then
  source ~/.config/zsh/.zshrc.minimal
  return
fi

# ⎧                                        ⎫
# ⎨  Init stuff                            ⎬
# ⎩                                        ⎭
# ZSH_THEME="common"
# if [ -f ~/.dircolors ] && command -v gdircolors > /dev/null 2>&1; then
#   eval "$(gdircolors -b ~/.dircolors)"
# fi
set -o vi
unsetopt BEEP
unsetopt LIST_BEEP

# init fzf
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi

# init pyenv (lazy-loaded to avoid startup overhead)
if [[ -d "${PYENV_ROOT}/bin" ]]; then
  pyenv() {
    unfunction pyenv
    eval "$(command pyenv init -)"
    eval "$(command pyenv virtualenv-init -)"
    pyenv "$@"
  }
fi

# Set directory for zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  # git clone https://github.com/zsharma-continuum/zinit.git "$ZINIT_HOME"
  git clone git@github.com:zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

#
# fpath for pass completion
#   i would love for this to be in ~/.zshenv but i have a sneaking
#   suspicion that `zinit.zsh` overwrites the fpath.
#
BREW_SHARE="/opt/homebrew/share"
BREW_ZSF="/opt/homebrew/share/zsh/site-functions"
export FPATH="${BREW_SHARE}:${BREW_ZSF}:${FPATH}"

# Get prompt
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Grab plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
# zinit light Aloxaf/fzf-tab

# Get snippets
zinit snippet OMZP::command-not-found
zinit snippet OMZP::safe-paste
# zinit snippet OMZP::virtualenv

# Snippets to check out
# zinit snippet OMZP::colored-man-pages
# zinit snippet OMZP::macos
# zinit snippet OMZP::yarn

# Load completions (only rebuild dump once per day)
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Reloads all cached completions? idk man recommended by the friendly manual
zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# ⎧                                        ⎫
# ⎨  Keybindings                           ⎬
# ⎩                                        ⎭
# For use with fzf-tab
bindkey '^y' autosuggest-accept # TODO switch to emacs mode?
bindkey '^n' history-search-forward
bindkey '^p' history-search-backward

if command -v tmux-sessionizer &> /dev/null && [[ $TERM != tmux* ]]; then
  # create zsh widget for tmux-sessionizer
  function _run() {
    BUFFER="tmux-sessionizer"
    zle accept-line
  }
  zle -N _run
  bindkey -M viins '^f' _run
  bindkey -M vicmd '^f' _run
fi

# ⎧                                        ⎫
# ⎨  Globals                               ⎬
# ⎩                                        ⎭
# Completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # ignore case on completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Source aliases
[[ -f ~/.config/zsh/.zaliases ]] && source ~/.config/zsh/.zaliases

# Source docker completions
source <(docker completion zsh)

# >>> conda initialize (lazy-loaded to avoid startup overhead) >>>
if [[ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]] || [[ -d "/opt/miniconda3/bin" ]]; then
  conda() {
    unfunction conda
    __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
      eval "$__conda_setup"
    else
      if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
      else
        export PATH="/opt/miniconda3/bin:$PATH"
      fi
    fi
    unset __conda_setup
    conda "$@"
  }
fi
# <<< conda initialize <<<

# Reauth CodeArtifcat credentials for spring
reauth_spring_aws() {
  # Check if token is missing OR older than 660 minutes (11 hours)
  # The '-n' check ensures the find command actually returned a result
  if [[ ! -f ~/.aws_codeartifact_token ]] || [[ -n $(find ~/.aws_codeartifact_token -mmin +660 2>/dev/null) ]]; then
    echo "AWS Token expired or missing. Refreshing..."
    aws codeartifact get-authorization-token \
      --domain ktechartifacts --domain-owner 356635979126 --region us-east-2 \
      --query authorizationToken --output text > ~/.aws_codeartifact_token
  fi

  # 3. Export for the current process
  echo "exporting code artifact token"
  export CODEARTIFACT_AUTH_TOKEN=$(cat ~/.aws_codeartifact_token)
}

# Maven wrapper for Spring AWS auth
mvn() {
  # Only act if we are in the spring work directory
  if [[ "$PWD" == "$HOME/work/spring"* ]]; then
    reauth_spring_aws
  fi

  # 4. Run the actual Maven command
  command mvn "$@"
}

# Intellij wrapper for Spring AWS auth
idea() {
  # Only act if we are in the spring work directory
  if [[ "$PWD" == "$HOME/work/spring"* ]]; then
    reauth_spring_aws
  fi

  # 4. Run the actual Maven command
  command idea "$@"
}

# Toggle menu bar to use with steam
toggle_game_mode() {
    if pgrep -x "AeroSpace" > /dev/null; then
        # Set Menu Bar to ALWAYS SHOW
        osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to false'
        # Quit Sketchybar
        pkill -x sketchybar
        # Gracefully tell AeroSpace to quit
        osascript -e 'tell application "AeroSpace" to quit'
    else
        # Set Menu Bar to AUTO-HIDE
        osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to true'
        # Open AeroSpace
        open -a "AeroSpace"
    fi
}

# Build rust dockerfile with current directory mounted as volume
ubuntu() {
    local DOCKERFILE_PATH="/Users/ickoxii/.local/templates/docker/ubuntu/rust.Dockerfile"
    local CONTEXT_DIR=$(dirname "$DOCKERFILE_PATH")
    local IMAGE_NAME="ubuntu-rust-proto"

    # 1. Build the image (uses cache if available, pulls if missing)
    docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" "$CONTEXT_DIR"

    # 2. Run the container with the current directory mounted
    # --rm flag removes a container on exit
    # docker run -it --rm \
    #     -v "$PWD":/work \
    #     -w /work \
    #     "$IMAGE_NAME"
    docker run -dit \
        -v "$PWD":/work \
        -w /work \
        "$IMAGE_NAME"
}

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="${SDKMAN_HOME}"
[[ -s "${SDKMAN_HOME}/bin/sdkman-init.sh" ]] && source "${SDKMAN_HOME}/bin/sdkman-init.sh"
