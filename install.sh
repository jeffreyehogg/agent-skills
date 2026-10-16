#!/usr/bin/env bash
# ==============================================================================
# agent-skills installer
# Symlinks skill directories into Antigravity global configuration.
# ==============================================================================

set -euo pipefail

SKILLS_TARGET_DIR="${HOME}/.gemini/config/skills"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$SKILLS_TARGET_DIR"

if [[ "${1:-}" == "--uninstall" ]]; then
  echo "Uninstalling agent-skills symlinks from $SKILLS_TARGET_DIR..."
  for entry in "$REPO_DIR"/*/; do
    if [[ -f "${entry}SKILL.md" ]]; then
      skill_name="$(basename "$entry")"
      target_link="$SKILLS_TARGET_DIR/$skill_name"
      if [[ -L "$target_link" ]]; then
        rm "$target_link"
        echo "  - Removed symlink: $skill_name"
      fi
    fi
  done
  echo "Uninstall complete."
  exit 0
fi

echo "Installing agent-skills into $SKILLS_TARGET_DIR..."
installed_count=0

for entry in "$REPO_DIR"/*/; do
  if [[ -f "${entry}SKILL.md" ]]; then
    skill_name="$(basename "$entry")"
    target_link="$SKILLS_TARGET_DIR/$skill_name"
    
    # Create or update symbolic link
    ln -sfn "$entry" "$target_link"
    echo "  ✓ Linked skill: $skill_name -> $entry"
    ((installed_count++))
  fi
done

echo "Successfully linked $installed_count skill(s)."
