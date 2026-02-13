#!/bin/sh

engine="$1"

if [ -z "$engine" ];then
  search_engine=$(printf "Google\nDuckDuckGo\nYouTube\nBing\nSearx\nOdysee" | sort | wmenu -i -l 6 -p "Choose Search:")
else
  search_engine="$engine"
  # notify-send "engine:" "$search_engine"
fi
#
# case "$search_engine" in 
#     "Google")
#         echo $(echo "" | "$cmd" -p "Google Search:" | xargs -I{} xdg-open https://www.google.com/search?q={})
# 	;;
#     "DuckDuckGo")
#         echo $(echo "" | "$cmd" -p "DuckDuckGo Search:" | xargs -I{} xdg-open https://www.duckduckgo.com/?q={})
# 	;;
#     "YouTube")
#         echo $(echo "" | "$cmd" -p "YouTube Search:" | xargs -I{} xdg-open https://www.youtube.com/results?search_query={})
# 	;;
#     "Bing")
#         echo $(echo "" | "$cmd" -p "Bing Search:" | xargs -I{} xdg-open https://www.bing.com/search?q={})
# 	;;
#     "Searx")
#         echo $(echo "" | "$cmd" -p "Searx Search:" | xargs -I{} xdg-open https://searx.tiekoetter.com/search?q={})
# 	;;
#     "Odysee")
#         echo $(echo "" | "$cmd" -p "Odysee Search:" | xargs -I{} xdg-open https://odysee.com/$/search?q={})
# esac
#


# Read input using wmenu
query="$(echo "" | wmenu -p "Web ⟶")"

# Exit if user pressed Escape or entered nothing
[ -z "$query" ] && exit 0

# Trim whitespace
query="$(echo "$query" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

# Case 1: If it looks like a full URL (http://, https://, or ftp:// etc.)
if echo "$query" | grep -E '^https?://' >/dev/null || echo "$query" | grep -E '^ftps?://' >/dev/null; then
    xdg-open "$query"

# Case 2: If it contains a dot and no spaces → probably a domain (like arch.org, www.example.com, subdomain.site.co.uk)
elif echo "$query" | grep -E '^[^[:space:]]*\.[^[:space:]]*$' >/dev/null && ! echo "$query" | grep -E '[[:space:]]' >/dev/null; then
    # Add https:// if not present
    if echo "$query" | grep -E '^https?://' >/dev/null; then
        xdg-open "$query"
    else
        xdg-open "https://$query"
    fi

# Case 3: Everything else → Google search
else
    xdg-open "https://www.google.com/search?q=$(printf '%s' "$query" | jq -sRr @uri)"
fi
