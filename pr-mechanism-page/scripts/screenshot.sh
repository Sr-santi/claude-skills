#!/usr/bin/env bash
# One look at a page before publishing: headless Chrome, full height. Usage: screenshot.sh page.html out.png [width] [height]
set -euo pipefail
C="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
IN=$(cd "$(dirname "$1")" && pwd)/$(basename "$1"); OUT=$2; W=${3:-1100}; H=${4:-7000}
TMP=$(mktemp -t preview).html
{ printf '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width">'; cat "$IN"; } > "$TMP"
"$C" --headless=new --disable-gpu --hide-scrollbars --window-size="$W,$H" --screenshot="$OUT" "file://$TMP" 2>/dev/null
rm -f "$TMP"; echo "$OUT"
