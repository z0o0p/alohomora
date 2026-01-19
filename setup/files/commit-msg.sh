#!/bin/bash

allowed_message_format='^(Add|Update|Fix)(\(.+\))? - (.|\n)+'
commit_message=$(<$1)

if ! [[ "$commit_message" =~ $allowed_message_format ]]; then
    echo "Error: Invalid commit message format. Please refer to the contributing guidelines."
    exit 1
fi
exit 0

