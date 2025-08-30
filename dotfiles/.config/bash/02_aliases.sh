#!/bin/bash

# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi

    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias d=dirs
alias e='emacsclient -c'
alias L="ls -Falog | more"
alias ll='ls -lFa'
alias lt='ls -Flrta --color'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep -i --color=auto'
alias grepn='grep -n -i --color=auto'
alias rgrep='grep -n -i -r --color=auto --exclude=*~'
alias ..='cd ..'

alias tk='tkdiff -w'
alias ffile='find . | grep'

alias hgrep="history|'grep'"
alias psgrep="ps -Af|'grep'"
