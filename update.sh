#!/bin/bash

# Ensure we are in the English locale for Git output (as per user preference)
export LANG=en_US.UTF-8

echo "--- Automation Script Starting ---"

# 1. Check for dirty working tree and stash if necessary
DIRTY=false
if ! git diff --quiet; then
    echo "Local changes detected. Stashing..."
    git stash
    DIRTY=true
fi

# 2. Pull with rebase
echo "Syncing with remote GitHub repository..."
if ! git pull origin main --rebase; then
    echo "Error: Pull failed. You might have manual conflicts to resolve."
    exit 1
fi

# 3. Pop stash if we moved anything
if [ "$DIRTY" = true ]; then
    echo "Restoring local changes from stash..."
    git stash pop
fi

# 4. Standard Add-Commit-Push flow
echo "Processing deployment..."
git add .

# Avoid empty commits
if git diff-index --quiet HEAD --; then
    echo "No new changes to push."
else
    git commit -m "Site update: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
fi

echo "--- Process Finished ---"