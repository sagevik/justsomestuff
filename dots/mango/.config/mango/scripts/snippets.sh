#!/bin/sh

# Script for storing/retrieving snippets in/from a file

font="Hack Bold 16"

snippet_file="$HOME/dox/snippets"

ensure_snippet_file() {
    snippet_dir=$(dirname "$snippet_file")

    if [ ! -d "$snippet_dir" ]; then
        mkdir -p "$snippet_dir"
        notify-send "Snippets" "Directory for snippets created"
    fi

    if [ ! -f "$snippet_file" ]; then
        touch "$snippet_file"
        notify-send "Snippets" "Snippet file created"
    fi
}

get_snippet() {
    # Put snippet on clipboard
    selection=$(
      grep -v '^#' "$snippet_file" |
      grep -v '^[[:space:]]*$' |
      wmenu -f "$font" -i -c -l 10 -p "Get snippet:"
    )
    [ -z "$selection" ] && exit 0

    printf '%s' "$selection" | wl-copy -n
    notify-send "Snippet" "Copied to clipboard"
}

set_snippet() {
    snippet="$(wl-paste -n)"
    if [ -z "$snippet" ] || [ "$(echo "$snippet" | tr -d  '[:space:]')" = "" ]; then
        notify-send "Error" "Cannot save empty snippet"
        exit 0
    fi

    ensure_snippet_file
    if grep -q "^$snippet$" "$snippet_file"; then
        notify-send "!!!" "Already snippeted"
    else
        echo "$snippet" >> "$snippet_file"
        notify-send "Snippet added!" "$snippet is now saved to file"
    fi
}

if [ "$1" = "set" ]
then
    set_snippet
elif [ "$1" = "get" ]
then
    get_snippet
else
    foot -e nvim "$snippet_file"
fi

