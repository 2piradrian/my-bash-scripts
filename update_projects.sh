#!/bin/bash

BASE_DIR="$HOME/disk1/github"

# Para cada directorio en la base
for dir in "$BASE_DIR"/*/; do
  echo "Processing $dir ..."
  cd "$dir" || { echo "Could not enter $dir"; continue; }

  if [ ! -d ".git" ]; then
    echo "Not a Git repository, skipping."
    continue
  fi

  # Fetch silencioso
  git fetch --quiet

  # Obtener las ramas remotas
  remote_branches=$(git ls-remote --heads origin | awk '{print $2}' | sed 's|refs/heads/||')

  # Ramas que queremos actualizar
  for branch in main master develop; do
    if echo "$remote_branches" | grep -q "^$branch$"; then
      echo "Updating '$branch' branch..."

      # Eliminar index.lock si existe
      [ -f .git/index.lock ] && rm -f .git/index.lock

      # Cambiar a la rama o crearla si no existe
      git switch "$branch" 2>/dev/null || git checkout -b "$branch" origin/"$branch"

      # Pull con rebase para resolver divergencias automáticamente
      git pull --rebase --quiet origin "$branch"
    fi
  done

done

echo "Update complete."
