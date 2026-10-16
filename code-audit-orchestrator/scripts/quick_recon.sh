#!/usr/bin/env bash
# ==============================================================================
# quick_recon.sh
# Fast deterministic repository inspection to save LLM context tokens.
# ==============================================================================

set -euo pipefail

REPO_ROOT="${1:-.}"

echo "=== Repository Reconnaissance Report ==="
echo "Path: $(cd "$REPO_ROOT" && pwd)"
echo "Date: $(date -u)"
echo ""

echo "--- File Counts by Extension ---"
find "$REPO_ROOT" -type f \
  -not -path '*/.*' \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/target/*' \
  | sed -E -n 's/.*\.([a-zA-Z0-9]+)$/\1/p' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 15

echo ""
echo "--- Top 10 Largest Code Files ---"
find "$REPO_ROOT" -type f \
  -not -path '*/.*' \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/target/*' \
  -exec ls -lh {} + 2>/dev/null \
  | awk '{print $5, $9}' \
  | sort -hr \
  | head -n 10

echo ""
echo "--- Potential Hotspots (Files with > 500 lines) ---"
find "$REPO_ROOT" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) \
  -not -path '*/.*' \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -exec wc -l {} + 2>/dev/null \
  | sort -nr \
  | awk '$1 > 500 {print $1 " lines: " $2}' \
  | head -n 10 || true

echo ""
echo "=== Recon Complete ==="
