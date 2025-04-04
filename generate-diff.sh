#!/bin/bash

# === CONFIGURATION ===
FILE_PATH="EN/asciidoc/src/10_quality_requirements.adoc"  # Path to the file relative to repo root
BASE_BRANCH="master"
COMPARE_BRANCH="9.0-draft"
OUTPUT_FILE="sec-10-v8-v9-diff.html"

# === WORK ===
echo "Generating diff for $FILE_PATH between $BASE_BRANCH and $COMPARE_BRANCH..."

# Ensure we're in the repo root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

# Generate the diff and pipe to diff2html
git diff "$BASE_BRANCH".."$COMPARE_BRANCH" -- "$FILE_PATH" | \
npx diff2html-cli -i stdin -s side -F "$OUTPUT_FILE" --format "html"

echo "✅ Diff saved to: $OUTPUT_FILE"
