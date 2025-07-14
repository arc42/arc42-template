#!/bin/bash

# Script to generate a markdown table of first commits per language directory
# Usage: ./script.sh

# Define the array of language codes
# Edit this array as needed for your repository
languages=("DE" "EN" "ES" "PT" "NL" "CZ" "IT" "RU" "UKR" "FR")

# Print header of markdown table
echo "| Language | First Commit Date | Author |"
echo "|----------|------------------|--------|"

# Loop through the predefined languages
for lang in "${languages[@]}"; do
    # Use the language code as the directory name
    lang_dir="./$lang"
    
    # Check if the directory exists
    if [ ! -d "$lang_dir" ]; then
        echo "| $lang | Directory not found | N/A |"
        continue
    fi
    
    # Get the first commit that affected files in this language directory
    # Format: date | author name <email> (committer ID)
    commit_info=$(git log --format="%ad | %an <%ae> (%H)" --date=short --reverse -- "$lang_dir" | head -n 1)
    
    # If we found a commit, add it to the table
    if [ -n "$commit_info" ]; then
        # Split the commit info into date and author parts
        commit_date=$(echo "$commit_info" | cut -d'|' -f1 | xargs)
        commit_author=$(echo "$commit_info" | cut -d'|' -f2 | xargs)
        
        # Output the table row
        echo "| $lang | $commit_date | $commit_author |"
    else
        # If no commits found for this directory
        echo "| $lang | No commits found | N/A |"
    fi
done