#!/bin/bash

BASE_DIR="$HOME/disk1/gh_projects"

# For every directory in the base directory
for dir in "$BASE_DIR"/*/; do
  echo "Processing $dir ..."
  cd "$dir" || { echo "Could not enter $dir"; continue; }

  if [ ! -d ".git" ]; then
    echo "Not a Git repository, skipping."
    continue
  fi

  # Fetch silently
  git fetch --quiet

  for branch in main master develop; do
    # Check if remote branch exists
    if git ls-remote --heads origin "$branch" &>/dev/null; then
      echo "Updating '$branch' branch..."
      # Try switching, fallback to creating tracking branch silently
      git switch --quiet "$branch" 2>/dev/null || git checkout -q -b "$branch" origin/"$branch" &>/dev/null
      git pull --quiet origin "$branch" &>/dev/null
    fi
  done

done

echo "Update complete."
