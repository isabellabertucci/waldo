#!/usr/bin/env bash
# Fails if a widget holds a raw design value instead of a token from
# lib/core/theme: a colour, a font size or weight, an animation duration,
# or a fractional opacity. Every such value has a named token in
# lib/core/theme (see DESIGN.md), so there is no exception marker.
#
# Not checked: the shape of a drawing inside a painter (the pouch's curve,
# the eye's path), and behaviour constants such as counts and time windows.
set -euo pipefail

cd "$(dirname "$0")/.."

violations=0

check() {
  local pattern="$1"
  local label="$2"
  local found
  found=$(grep -rnE "$pattern" lib/ --include="*.dart" | grep -v "^lib/core/theme/" || true)
  if [ -n "$found" ]; then
    echo "=== $label outside lib/core/theme ==="
    echo "$found"
    echo
    violations=$((violations + 1))
  fi
}

check 'Color\(0x' "Hardcoded Color(0x...)"
check '\bColors\.[a-z]' "Material Colors.*"
check 'fontSize:' "Raw fontSize:"
check 'fontWeight:' "Raw fontWeight:"
check 'Duration\(milliseconds' "Raw animation duration"
check 'alpha: 0\.[0-9]' "Raw opacity"

if [ "$violations" -gt 0 ]; then
  echo "Design guardrail failed: $violations categorie(s) with hardcoded values."
  echo "Use a token from lib/core/theme, or add one there and document it in DESIGN.md."
  exit 1
fi

echo "Design guardrail passed."
