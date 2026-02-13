#!/bin/sh

set -eu

FLAG="${1:-}"
FONT="Hack Bold 16"

# Bookmark file
BOOKMARKS_FILE="${BOOKMARKS_FILE:-$HOME/.config/bookmarks/bookmarks.txt}"

# wmenu cmd
WMENU="wmenu -i -w 500 -c -l 30 -f '$FONT' -p 'Bookmarks:'"

# Browsers
CHROME="$(command -v google-chrome-stable || true)"
BRAVE="$(command -v brave || command -v brave-browser || true)"
FALLBACK="$(command -v xdg-open || echo firefox)"

# Ensure file exists
mkdir -p "$(dirname "$BOOKMARKS_FILE")"
[ -f "$BOOKMARKS_FILE" ] || cat >"$BOOKMARKS_FILE" <<'EOF'
https://youtube.com
EOF

############################
# Helpers
############################

url_exists() {
  url="$1"
  grep -vE '^\s*(#|$)' "$BOOKMARKS_FILE" \
    | sed 's/.*::[[:space:]]*//' \
    | grep -Fxq "$url"
}

emit() {
  file="$1"
  [ -f "$file" ] || return 0

  grep -vE '^\s*(#|$)' "$file" | while IFS= read -r line; do
    case "$line" in
      *"::"*)
        lhs="${line%%::*}"
        rhs="${line#*::}"

        lhs="$(printf '%s' "$lhs" | sed 's/[[:space:]]*$//')"
        rhs="$(printf '%s' "$rhs" | sed 's/^[[:space:]]*//')"

        printf '%s :: %s\n' "$lhs" "$rhs"
        ;;
      *)
        printf '%s :: %s\n' "" "$rhs"
        # printf '%s :: %s ||| %s\n' "" "$short" "$line"
        ;;
    esac
  done
}

############################
# Actions
############################

add_bookmark() {
  BOOKMARK=$(wl-paste -n | tr -d '\n')

  [ -n "$BOOKMARK" ] || exit 0

  # Exit if bookmark exists, else ask for bookmark name
  if url_exists "$BOOKMARK"; then
    notify-send "Bookmark exists" "$BOOKMARK"
    exit 0
  fi

  BOOKMARK_NAME=$(echo -e "" | wmenu -i -w 1000 -c -l 0 -f "$FONT" -p "Bookmark name:")

  if [ -z "$BOOKMARK_NAME" ]; then
    printf " :: %s\n" "$BOOKMARK" >> "$BOOKMARKS_FILE"
  else
    printf "%s :: %s\n" "$BOOKMARK_NAME" "$BOOKMARK" >> "$BOOKMARKS_FILE"
  fi

  notify-send "Bookmark added" "$BOOKMARK_NAME\n\n$BOOKMARK"
  exit 0
}

edit_bookmark() {
  foot -e nvim "$BOOKMARKS_FILE"
  exit 0
}

remove_bookmark() {
  choice="$(emit "$BOOKMARKS_FILE" | sort | eval "$WMENU" || true)"
  [ -n "$choice" ] || exit 0

  raw="${choice##* ||| }"
  raw="$(printf '%s' "$raw" | sed 's/[[:space:]]*$//')"

  esc=$(printf '%s\n' "$raw" | sed 's/[.[\*^$(){}?+|/]/\\&/g')

  tmp="$(mktemp)"
  grep -vE "(::[[:space:]]*)?$esc([[:space:]]*(#.*)?)?$" "$BOOKMARKS_FILE" > "$tmp"
  mv "$tmp" "$BOOKMARKS_FILE"

  notify-send "Bookmark removed" "$raw"
  exit 0
}

############################
# Main menu
############################

choice="$({
  printf '%s\n' "ADD"
  printf '%s\n' "EDIT"
  printf '%s\n' "REMOVE"
  emit "$BOOKMARKS_FILE" | sort
} | eval "$WMENU" || true)"

[ -n "$choice" ] || exit 0

[ "$choice" = "ADD" ] && add_bookmark
[ "$choice" = "EDIT" ] && edit_bookmark
[ "$choice" = "REMOVE" ] && remove_bookmark

############################
# Open selected URL
############################

raw="${choice##* }"

raw="$(printf '%s' "$raw" \
  | sed -e 's/[[:space:]]\+#.*$//' \
        -e 's/[[:space:]]\/\/.*$//' \
        -e 's/^[[:space:]]*//' \
        -e 's/[[:space:]]*$//')"

case "$raw" in
  http://*|https://*|file://*|about:*|chrome:*) url="$raw" ;;
  *) url="https://$raw" ;;
esac

open_with() {
  cmd="$1"
  if [ -n "$cmd" ]; then
    nohup "$cmd" --new-tab "$url" >/dev/null 2>&1 & exit 0
  fi
}

open_with "$BRAVE"

nohup $FALLBACK "$url" >/dev/null 2>&1 &
