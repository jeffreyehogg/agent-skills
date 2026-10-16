#!/usr/bin/env bash
# ==============================================================================
# quick_recon.sh
# Fast deterministic repository inspection to save LLM context tokens.
# ==============================================================================

set -euo pipefail

REPO_ROOT="${1:-.}"
if [[ ! -d "$REPO_ROOT" ]]; then
  echo "ERROR: Directory not found: $REPO_ROOT" >&2
  exit 1
fi

ABS_ROOT="$(cd "$REPO_ROOT" && pwd)"

# Portable helper to prune heavy/ignored directories before traversal
find_repo_files() {
  find "$ABS_ROOT" \
    \( -name ".git" -o -name "node_modules" -o -name "dist" -o -name "build" \
       -o -name "target" -o -name ".next" -o -name ".venv" -o -name "vendor" \
       -o -name ".worktrees" -o -name ".audit" \) -prune \
    -o -type f "$@" -print
}

echo "=== Repository Reconnaissance Report ==="
echo "REPO_ROOT=$ABS_ROOT"
echo "TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

FRONTEND_COUNT="$(find_repo_files \( -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" -o -name "*.astro" -o -name "*.css" -o -name "*.scss" -o -name "*.html" \) | wc -l | tr -d ' ')"
if [[ "$FRONTEND_COUNT" -gt 0 ]]; then
  echo "HAS_FRONTEND=true (frontend_files=$FRONTEND_COUNT)"
else
  echo "HAS_FRONTEND=false (frontend_files=0)"
fi
echo ""

echo "--- File Counts by Extension ---"
find_repo_files \
  | awk -F/ '{print $NF}' \
  | awk -F. '(NF>2 || (NF==2 && $1 != "")) && $NF ~ /^[a-zA-Z0-9]+$/ {print tolower($NF)}' \
  | sort \
  | uniq -c \
  | sort -nr \
  | awk 'NR<=15 {printf "  %6d .%s\n", $1, $2}'

echo ""
echo "--- Top 10 Largest Files (Bytes) ---"
find_repo_files -exec wc -c {} + 2>/dev/null \
  | awk '$2 != "total" {
      bytes=$1; $1=""; sub(/^ +/, "");
      printf "%10d  %s\n", bytes, $0
    }' \
  | sort -nr \
  | awk -v root="$ABS_ROOT/" 'NR<=10 {
      bytes=$1; $1=""; sub(/^ +/, "");
      sub("^" root, "");
      printf "  %8.1f KB  %s\n", bytes/1024, $0
    }'

echo ""
echo "--- Potential Hotspots (Files with > 500 lines) ---"
find_repo_files \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.jsx" \
  -o -name "*.vue" -o -name "*.svelte" -o -name "*.astro" -o -name "*.css" -o -name "*.scss" \
  -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.rb" \) \
  -exec wc -l {} + 2>/dev/null \
  | awk '$2 != "total" && $1 > 500 {
      lines=$1; $1=""; sub(/^ +/, "");
      printf "%8d  %s\n", lines, $0
    }' \
  | sort -nr \
  | awk -v root="$ABS_ROOT/" 'NR<=10 {
      lines=$1; $1=""; sub(/^ +/, "");
      sub("^" root, "");
      printf "  %6d lines  %s\n", lines, $0
    }'

echo ""
echo "=== Recon Complete ==="
