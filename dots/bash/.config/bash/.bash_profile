#
# ~/.bash_profile
#

[[ -f ~/.config/bash/.bashrc ]] && . ~/.config/bash/.bashrc

if [[ -f ~/.config/bash/.bash_logout ]]; then
    trap 'source ~/.config/bash/.bash_logout' EXIT
fi

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    startx
fi
