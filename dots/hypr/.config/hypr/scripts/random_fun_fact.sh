#!/bin/bash

# # Script to fetch a random fun fact from uselessfacts.jsph.pl
# API_URL="https://uselessfacts.jsph.pl/api/v2/facts/random"
#
# # Function to check if a command is available
# command_exists() {
#     command -v "$1" >/dev/null 2>&1
# }
#
# # Try fetching with curl and parse with jq if available
# if command_exists curl && command_exists jq; then
#     fact=$(curl -s "$API_URL" | jq -r '.text')
#     if [ $? -eq 0 ] && [ -n "$fact" ]; then
#         echo "$fact"
#         exit 0
#     else
#         echo "?" >&2
#         exit 0
#     fi
# # Fallback to grep and sed if jq is not installed
# elif command_exists curl; then
#     fact=$(curl -s "$API_URL" | grep -oP '"text":\s*"\K[^"]+' | sed 's/\\//g')
#     if [ $? -eq 0 ] && [ -n "$fact" ]; then
#         echo "$fact"
#         exit 0
#     else
#         echo "?" >&2
#         exit 0
#     fi
# else
#     echo "?" >&2
#     exit 0
# fi
#


# Script to fetch a random fun fact from uselessfacts.jsph.pl with a max length of 150 characters
API_URL="https://uselessfacts.jsph.pl/api/v2/facts/random"
MAX_LENGTH=150
MAX_ATTEMPTS=5

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to fetch a fact
fetch_fact() {
    if command_exists curl && command_exists jq; then
        fact=$(curl -s "$API_URL" | jq -r '.text')
        if [ $? -eq 0 ] && [ -n "$fact" ]; then
            echo "$fact"
            return 0
        fi
    elif command_exists curl; then
        fact=$(curl -s "$API_URL" | grep -oP '"text":\s*"\K[^"]+' | sed 's/\\//g')
        if [ $? -eq 0 ] && [ -n "$fact" ]; then
            echo "$fact"
            return 0
        fi
    fi
    echo ""
    return 1
}

# Try fetching a fact with length <= 150 characters
attempt=1
while [ $attempt -le $MAX_ATTEMPTS ]; do
    fact=$(fetch_fact)
    if [ $? -eq 0 ] && [ -n "$fact" ]; then
        fact_length=${#fact}
        if [ $fact_length -le $MAX_LENGTH ]; then
            echo "$fact"
            exit 0
        fi
    fi
    attempt=$((attempt + 1))
done

echo "?" >&2
# echo "Error: Could not fetch a fact with 150 or fewer characters after $MAX_ATTEMPTS attempts" >&2
exit 0
