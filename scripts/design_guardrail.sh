#!/usr/bin/env bash
# Fails if a hardcoded Color(0x...) or raw `fontSize:` number appears
# outside lib/core/theme - the two most mechanically-checkable categories
# from DESIGN.md's rules. A line with a real, reviewed
# reason for being an exception is marked `// one-off` within a couple of
# lines (see DESIGN.md's Known Gaps for the
# reasoning behind each one) - checked as a window rather than requiring
# the marker on the exact same line, since `dart format` is free to
# rewrap a multi-line call and move a trailing comment to a different
# physical line than the value it documents.
#
# Note: this intentionally does not yet check raw EdgeInsets/SizedBox
# numbers - see DESIGN.md's Known Gaps for why that check is deferred.
set -euo pipefail

cd "$(dirname "$0")/.."

violations=0

check() {
  local pattern="$1"
  local label="$2"
  local file
  local unmarked=""
  for file in $(grep -rl "$pattern" lib/ --include="*.dart" | grep -v "lib/core/theme/"); do
    local lines
    lines=$(grep -n "$pattern" "$file" | cut -d: -f1)
    for line in $lines; do
      local window
      window=$(sed -n "$((line > 2 ? line - 2 : 1)),$((line + 2))p" "$file")
      if ! echo "$window" | grep -q "one-off"; then
        unmarked="$unmarked$file:$line: $(sed -n "${line}p" "$file")"$'\n'
      fi
    done
  done
  if [ -n "$unmarked" ]; then
    echo "=== $label outside lib/core/theme ==="
    echo "$unmarked"
    violations=$((violations + 1))
  fi
}

check 'Color(0x' "Hardcoded Color(0x...)"
check 'fontSize: [0-9]' "Raw fontSize:"

if [ "$violations" -gt 0 ]; then
  echo "Design guardrail failed: $violations categorie(s) with hardcoded values."
  echo "Replace with a lib/core/theme token, or mark a reviewed exception with '// one-off'."
  exit 1
fi

echo "Design guardrail passed."
