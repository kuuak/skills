#!/usr/bin/env bash
# Render a report HTML to a PDF beside it, then each page to a PNG for checking.
# Usage: render.sh <report.html> [png-dir]
set -euo pipefail

html="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
pdf="${html%.html}.pdf"
png_dir="${2:-$(mktemp -d)}"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
profile="$(mktemp -d)"

"$chrome" --headless=new --disable-gpu --no-pdf-header-footer \
  --user-data-dir="$profile" --print-to-pdf="$pdf" "file://$html" 2>/dev/null
rm -rf "$profile"

mkdir -p "$png_dir"
rm -f "$png_dir"/page-*.png
if command -v pdftoppm >/dev/null; then
  pdftoppm -png -r 100 "$pdf" "$png_dir/page"
else
  swift "$(dirname "$0")/pages.swift" "$pdf" "$png_dir"
fi

echo "pdf: $pdf"
echo "pages: $(ls "$png_dir"/page-*.png | wc -l | tr -d ' ') in $png_dir"
