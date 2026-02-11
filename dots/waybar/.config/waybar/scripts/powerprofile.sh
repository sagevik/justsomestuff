#!/usr/bin/env bash

get_profile() {
    profile=$(powerprofilesctl get)
    case "$profile" in
        "balanced")
            icon="⚖️ "
            text="Balanced"
            ;;
        "performance")
            icon="⚡ "
            text="Performance"
            ;;
        "power-saver")
            icon="♻️ "
            text="Power Saver"
            ;;
        *)
            icon="❓ "
            text="Unknown"
            ;;
    esac
    # Output just the icon by default. 
    # For icon + text: echo "{\"text\": \"$icon $text\", \"tooltip\": \"Power Profile: $text\", \"class\": \"$profile\"}"
    # For just text: echo "{\"text\": \"$text\", \"tooltip\": \"Power Profile: $text\", \"class\": \"$profile\"}"
    echo "{\"text\": \"$icon\", \"tooltip\": \"Power Profile: $text\", \"class\": \"$profile\"}"
}

get_profile

