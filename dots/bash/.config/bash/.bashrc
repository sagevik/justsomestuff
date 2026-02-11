#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# ----------> Colors <---------- #
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
YELLOW="\[\e[1;33m\]"
BLUE="\[\e[1;34m\]"
PURPLE="\[\e[1;35m\]"
CYAN="\[\e[1;36m\]"
RESET="\[\e[m\]"


# ----------> Colored man pages <---------- #
# from: https://wiki.archlinux.org/index.php/Color_output_in_console#man
export LESS_TERMCAP_mb=$'\e[1;32m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline

export PAGER="less --use-color -Dd+r -Du+b +Gg"
export MANPAGER="less --use-color -Dd+r -Du+b +Gg"


# ----------> Exports <---------- #
export BROWSER="brave"
export EDITOR="vim"
export VISUAL="vim"
export MYVIMRC="$HOME/.config/vim/.vimrc"
export VIMINIT="source $MYVIMRC"
export LESSHISTFILE=-
export HISTFILE="$HOME/.config/bash/.bash_history"
export INPUTRC="$HOME/.config/bash/.inputrc"
export GIT_CONFIG_GLOBAL="$HOME/.config/git/.gitconfig"

export XCURSOR_SIZE=16
export LIBVIRT_DEFAULT_URI=qemu:///system
export GOPATH="$HOME/dev/go"


# ----------> Bash <---------- #
source /usr/share/bash-completion/bash_completion
source $HOME/.config/bash/bash-functions.bash


# ----------> Alias <---------- #
alias reload="source ~/.config/bash/.bashrc"
alias sctl="sudo systemctl"

alias ..="cd .."

alias ls="ls --color=auto"
alias la="ls -a --color=auto"
alias ll="ls -l --color=auto"
alias lla="ls -la --color=auto"
alias grep="grep --color=auto"

alias mv="mv -iv"

# Git
source "$HOME/.config/bash/git-completion.bash"
alias ga="git add"
alias gst="git status"
alias gc="git commit"
alias gb="git branch"
alias gp="git push"
alias gls="git ls-files"
alias glods="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
alias grv="git remote -v"
alias cfg="/usr/bin/git --git-dir=$HOME/config/ --work-tree=$HOME"

# Vim
alias v="vim"

# Edit configs
alias bashrc="vim ~/.config/bash/.bashrc"
alias xinitrc="vim ~/.xinitrc"
alias profile="vim ~/.config/bash/.bash_profile"
alias vimrc="vim ~/.config/vim/.vimrc"

# Jotta
alias jc="jotta-cli"
alias jcs="jotta-cli status"
alias jco="jotta-cli observe"
alias jcls="jotta-cli ls Backup/$HOSTNAME"


# ----------> Functions <---------- #

#cd() {
#    [[ $# -eq 0 ]] && return
#    builtin cd "$@"
#}

fzfcd() {
#    cd $1
    if [ -z $1 ]
    then
        #selection="$(ls -a | fzf --height 40% --reverse --border)"
        selection="$(ls -d */ | fzf --reverse --border)"
        if [[ -d "$selection" ]]
        then
            cd "$selection"
        elif [[ -f "$selection" ]]
        then
            echo "$selection is a file"
        fi
    fi
}
alias f=fzfcd


# ----------> Archive Extract <---------- #

ex ()
{
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1   ;;
        *.tar.gz)    tar xzf $1   ;;
        *.bz2)       bunzip2 $1   ;;
        *.rar)       unrar x $1   ;;
        *.gz)        gunzip $1    ;;
        *.tar)       tar xvf $1   ;;
        *.tbz2)      tar xjf $1   ;;
        *.tgz)       tar xzvf $1  ;;
        *.zip)       unzip $1     ;;
        *.Z)         uncompress $1;;
        *.7z)        7za e x $1   ;;
        *.deb)       ar x $1      ;;
        *.tar.xz)    tar xf $1    ;;
        *.tar.zst)   unzstd $1    ;;
        *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
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
	echo "$YELLOW($BRANCH$RED$(parse_git_dirty)$YELLOW)"
    fi
}

update_prompt() {
    if [[ -n "$DISPLAY" ]] || [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
        #PS1="$GREEN[$YELLOW\u$GREEN@$CYAN\h $GREEN\w]$(git_status)$GREEN\$ $RESET"
        #PS1="$CYAN $YELLOW\u$GREEN@$CYAN\h $GREEN\w $(git_status)$CYAN $RESET"
        PS1="$CYAN  $GREEN\w$(git_status)$CYAN  $RESET"
    else
        # Simpler prompt for TTY
        PS1="$GREEN[$YELLOW\u$GREEN@$CYAN\h $GREEN\w]$(git_status)$GREEN\$ $RESET"
    fi

}

PROMPT_COMMAND=update_prompt

