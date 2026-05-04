#!/usr/bin/env bash
# Git Bash / macOS/Linux: prefetch Gradle ZIP for Flutter Android builds.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROP="$ROOT/android/gradle/wrapper/gradle-wrapper.properties"
LINE="$(grep '^distributionUrl=' "$PROP")"
RAW="${LINE#distributionUrl=}"
RAW="${RAW//\\/}" # remove Gradle property escape backslashes → https://...
URL_PRIMARY="${RAW//\\:/:}"

VERS="$(echo "$URL_PRIMARY" | sed -n 's/.*gradle-\([0-9][0-9]*\.[0-9][0-9]*\)-all\.zip.*/\1/p')"
if [[ -z "$VERS" ]]; then
  echo "Could not infer Gradle version from $URL_PRIMARY" >&2
  exit 1
fi

HASH_DIR=""
if [[ "$URL_PRIMARY" == *"mirrors.cloud.tencent.com"* ]]; then HASH_DIR="8mguqc37c200i71ledpgw8n5m"
elif [[ "$URL_PRIMARY" == *"services.gradle.org"* ]]; then HASH_DIR="c2qonpi39x1mddn7hk5gh9iqj"
else
  echo "Add hash mapping in scripts/preload_gradle.sh for:" >&2
  echo "  $URL_PRIMARY" >&2
  exit 1
fi

TARGET_DIR="$HOME/.gradle/wrapper/dists/gradle-${VERS}-all/$HASH_DIR"
ZIP="$TARGET_DIR/gradle-${VERS}-all.zip"
mkdir -p "$TARGET_DIR"
rm -f "$TARGET_DIR"/*.lck "$TARGET_DIR"/*.part || true

if [[ -f "$ZIP" ]] && [[ $(wc -c < "$ZIP") -gt 200000000 ]]; then
  echo "Already have Gradle zip ($(du -h "$ZIP" | cut -f1))."
  exit 0
fi
rm -f "$ZIP"

MIRRORS=("$URL_PRIMARY" "https://mirrors.cloud.tencent.com/gradle/gradle-8.14-all.zip" "https://services.gradle.org/distributions/gradle-8.14-all.zip")
readarray -t MIRROR_U < <(printf '%s\n' "${MIRRORS[@]}" | awk '!a[$0]++')

for U in "${MIRROR_U[@]}"; do
  echo "Trying: $U"
  if curl -fL --retry 25 --retry-delay 4 --connect-timeout 60 --continue-at - -o "$ZIP" "$U" && [[ -f "$ZIP" ]] && [[ $(wc -c < "$ZIP") -gt 200000000 ]]; then
    echo "OK: $ZIP — run flutter run -d emulator-5554"
    exit 0
  fi
  rm -f "$ZIP"
done

echo "All mirrors failed." >&2
exit 1
