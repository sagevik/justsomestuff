# --- Colors ---
[[ -f ~/.config/zsh/colors.zsh ]] && source ~/.config/zsh/colors.zsh

export XDG_CONFIG_HOME="$HOME/.config"

export PATH="$HOME/scripts/bin:$HOME/scripts/apps:$HOME/.local/bin:$PATH"

# bob managed nvim
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

export BROWSER="brave"
export EDITOR="nvim"
export VISUAL="nvim"
export LESSHISTFILE=-
export GIT_CONFIG_GLOBAL="$HOME/.config/git/.gitconfig"
export XCURSOR_SIZE=16
export LIBVIRT_DEFAULT_URI="qemu:///system"
export GOPATH="$HOME/dev/go"
export PATH="$HOME/dev/go/bin:$PATH"
export MANPAGER="nvim +Man!"
export MANROFFOPT="-c"
# avoid blank webview (peek.nvim)
export WEBKIT_DISABLE_COMPOSITING_MODE=1
export NEWT_COLORS=$(<~/.config/nmtui/palette)

# Basic auto/tab complete:
autoload -Uz compinit
setopt PROMPT_SUBST
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-Z}'
zstyle ':completion:*' menu select

zmodload zsh/complist
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v

# ----------> Aliases <---------- #
alias reload="source $HOME/.config/zsh/.zshrc"

# cd
alias ..="cd .."

# ls
alias ls="eza --color=always --icons=never -g"
# alias ls="ls --color"
alias ll="ls -l"
alias la="ls -a"
alias lc="ls | wc -l"
alias lla="ls -la"

# Git
alias ga="git add"
alias gb="git branch"
alias gc="git commit"
alias gd="git diff"
alias glods="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
alias gls="git ls-files"
alias gp="git push"
alias grv="git remote -v"
alias gst="git status"

# tmux
bindkey -s '^@' "tmx\n"
alias t=tmx
alias tmls="tmux ls"
alias tmcheat="nvim -O $HOME/.config/tmux/tmux-cht-languages $HOME/.config/tmux/tmux-cht-command"

# div
# alias pwdc="pwd | tr -d '\n' | xclip -selection clipboard && notify-send 'pwd' 'path copied to clipboard'"

# ----------> Functions <---------- #
function pwdc() {
    echo -n "$(pwd)" | wl-copy
    # pwd | xclip -selection clipboard
    notify-send "pwd" "path copid to clipboard"
}

function pdf() {
    if [ -z "$1" ]; then
        pdfdoc="$(fd . '/home/rs/' -e pdf | fzf)"
    else
        pdfdoc="$(fd . -e pdf | fzf)"
    fi
    if [ -z "$pdfdoc" ]; then
        return
    elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
       # zathura "$pdfdoc" & disown
       zathura --fork "$pdfdoc" && exit
    else
        devour zathura "$pdfdoc"
    fi
}

# Zathura pdf
# alias fpdf='zathura --fork "$(fd . -e pdf | fzf)" 2>/dev/null && exit || [ -z "$1" ]; return'
# alias fpdf='devour zathura "$(fd . -e pdf | fzf)" 2>/dev/null || [ -z "$1" ]; return'

# Open document with fzf, using neovim for text files and xdg-open for others
# function opendocument() {
#     local file="$1"
#
#     # Exit if no file is provided
#     if [ -z "$file" ]; then
#         echo "No file selected."
#         return 1
#     fi
#
#     # Check if file exists
#     if [ ! -f "$file" ]; then
#         echo "Error: File '$file' does not exist."
#         return 1
#     fi
#
#     # List of file extensions to open in neovim
#     local text_extensions="txt md sh py js ts json yaml yml toml c cpp java go rs vim zsh"
#
#     # Get the file extension (converted to lowercase), if any
#     local ext="${file##*.}"
#     ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
#
#     # Check if the file has no extension or an unrecognized extension
#     if [ "$ext" = "$file" ] || ! echo "$text_extensions" | grep -qw "$ext"; then
#         # Use file command to check if it's a text file
#         if file --mime-type "$file" | grep -q 'text/'; then
#             # Open in neovim if it's a text file
#             foot -e nvim "$file" & disown
#         else
#             # Open with default application using xdg-open
#             # devour xdg-open "$file" 2>/dev/null || {
#             foot -e xdg-open "$file" 2>/dev/null & disown || {
#                 echo "Error: Failed to open '$file' with xdg-open."
#                 return 1
#             }
#         fi
#     else
#         # Open in neovim if the extension is in text_extensions
#         foot -e nvim "$file" & disown
#     fi
# }


function opendocument() {
    local file="$1"

    if [ -z "$file" ]; then
        echo "No file selected."
        return 1
    fi

    if [ ! -f "$file" ]; then
        echo "Error: File '$file' does not exist."
        return 1
    fi

    local text_extensions="txt md sh py js ts json yaml yml toml c cpp java go rs vim zsh"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    if [ "$ext" = "$file" ] || ! echo "$text_extensions" | grep -qw "$ext"; then
        if file --mime-type "$file" | grep -q 'text/'; then
            (foot -e nvim "$file" &)
        else
            (xdg-open "$file" &)
        fi
    else
        (foot -e nvim "$file" &)
    fi

    disown
    exit
}


# Alias to search files with fd and fzf, then pass to opendocument
alias op='opendocument "$(fd . --type f | fzf --prompt="Open file > ")"'


# ----------> Yazi <---------- #
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

#cd() {
#    [[ $# -eq 0 ]] && return
#    builtin cd "$@"
#}

fzfcd() {
#    cd $1
    if [ -z $1 ]
    then
        selection="$(fzf --no-preview --border)"
        # selection="$(fzf --no-preview --reverse --border)"
        if [[ -d "$selection" ]]
        then
            cd "$selection"
        elif [[ -f "$selection" ]]
        then
            cd "$(dirname $selection)"
        fi
    fi
}
alias f=fzfcd

# ----------> Archive Extract <---------- #

ex () {
    if [ -f "$1" ] ; then
        # Extract base name without extension for folder creation
        folder_name="${1%.*}"

        # Create the folder and extract into it
        mkdir -p "$folder_name" && cd "$folder_name"

        case "$1" in
            *.tar.bz2)   tar xjf "../$1"   ;;
            *.tar.gz)    tar xzf "../$1"   ;;
            *.bz2)       bunzip2 "../$1"   ;;
            *.rar)       unrar x "../$1"   ;;
            *.gz)        gunzip "../$1"    ;;
            *.tar)       tar xvf "../$1"   ;;
            *.tbz2)      tar xjf "../$1"   ;;
            *.tgz)       tar xzvf "../$1"  ;;
            *.zip)       unzip "../$1"     ;;
            *.Z)         uncompress "../$1";;
            *.7z)        7za e "../$1"     ;;
            *.deb)       ar x "../$1"      ;;
            *.tar.xz)    tar xf "../$1"    ;;
            *.tar.zst)   unzstd "../$1"    ;;
            *)           echo "'$1' cannot be extracted via ex()" && cd .. && rmdir "$folder_name" ;;
        esac
        cd ..
    else
        echo "'$1' is not a valid file"
    fi
}

# ----------> Prompt <---------- #
parse_git_dirty() {
  STATUS="$(git status 2> /dev/null)"
  if [[ $? -ne 0 ]]; then printf ""; return; else printf " ["; fi
  if echo ${STATUS} | grep -c "renamed:"         &> /dev/null; then printf " >"; else printf ""; fi
  if echo ${STATUS} | grep -c "branch is ahead:" &> /dev/null; then printf " !"; else printf ""; fi
  if echo ${STATUS} | grep -c "new file::"       &> /dev/null; then printf " +"; else printf ""; fi
  if echo ${STATUS} | grep -c "Untracked files:" &> /dev/null; then printf " ?"; else printf ""; fi
  if echo ${STATUS} | grep -c "modified:"        &> /dev/null; then printf " *"; else printf ""; fi
  if echo ${STATUS} | grep -c "deleted:"         &> /dev/null; then printf " -"; else printf ""; fi
  printf " ]"
}

parse_git_branch() {
  # Long form
  git rev-parse --abbrev-ref HEAD 2> /dev/null
 # Short form
  # git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/.*\/\(.*\)/\1/'
}

git_status() {
    BRANCH=$(parse_git_branch)
    if [[ $? -ne 0 ]]
    then
        echo ""
	return
    else
        echo "%B%F{$ash}($(parse_git_branch)$(parse_git_dirty)) "
    fi
}

PROMPT='%B%F{$blue2}  %B%F{$green}%~ $(git_status)%B%F{$blue2} %b%F{$white}'
# RPROMPT='%b%F{$white}%T'
# PROMPT="%B%F{$red}[%F{$yellow}%n%F{$green}@%F{$blue2}%M %F{$pink}%~%F{i$red}]%F{$green}$(git_status)$%{$reset_color%}%b "

# Enable history appending and sharing
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
export SAVEHIST=10000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# History in cache directory:
HISTFILE=~/.cache/zsh/history

fh() {
    # Determine mode and set fzf prompt
    if [[ "$1" == "e" ]]; then
        mode="Execute"
        fzf_prompt="Execute > "
    else
        mode="Copy"
        fzf_prompt="Copy > "
    fi

    clear
    cmd=$(history 1 | fzf --height 100% --border --tac +s --prompt="$fzf_prompt")
    cmd=$(echo "$cmd" | sed 's/ *[0-9]\+\*\{0,1\} *//')

    [[ -z "$cmd" ]] && return 0

    echo "--> cmd: $cmd <--"

    # Handle mode: copy or execute
    if [[ "$mode" == "Execute" ]]; then
        # Execute the command
        eval "$cmd"
    else
        if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
          echo -n "$cmd" | wl-copy
        else
          echo -n "$cmd" | xclip -selection clipboard
        fi
        notify-send "Command" "$cmd\ncopied to clipboard!"
    fi
}

# alias for execute from history
alias fhe="fh e"

# Load zsh plugins
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/plugins/zsh-autoswitch-virtualenv/autoswitch_virtualenv.plugin.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#606065"

# fzf
export FZF_DEFAULT_OPTS="--no-preview --bind 'ctrl-a:select-all,ctrl-d:deselect-all'"
# export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always {}'"
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)"

# . "/home/rs/.deno/env"

[ -f "/home/rs/.ghcup/env" ] && . "/home/rs/.ghcup/env" # ghcup-env


# Update PATH and enable shell command completion for the Google Cloud SDK.
if [ -f '/home/rs/dev/google-cloud-sdk/path.zsh.inc' ]; then . '/home/rs/dev/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/home/rs/dev/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/rs/dev/google-cloud-sdk/completion.zsh.inc'; fi

