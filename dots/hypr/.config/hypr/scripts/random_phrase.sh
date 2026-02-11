#!/bin/bash
# File: ~/bin/random_phrase.sh
PHRASES=("Hello, world!" "Unlock to proceed" "Random fun fact!" "Try your luck" "Keep calm and type")
# PHRASES=("What is the similarity between a computer and an aircondition? It becomes useless the moment you open windows")
echo "${PHRASES[$RANDOM % ${#PHRASES[@]}]}"
