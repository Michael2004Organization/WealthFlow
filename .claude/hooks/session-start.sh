#!/bin/bash
# Richtet Flutter in Claude Code Cloud-Sessions ein, damit
# `flutter pub get`, `dart run build_runner build --workspace`, `flutter analyze` und
# `flutter test` sofort funktionieren. Das SDK liegt außerhalb des Repos und
# wird nach dem ersten Lauf aus dem Container-Cache wiederverwendet.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

FLUTTER_VERSION="3.47.6"
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"

# Eigene Markierung, damit ein abgebrochener Download beim nächsten Start neu geladen wird.
MARKER="$FLUTTER_HOME/.wealthflow-installed-version"
installed_version="$(cat "$MARKER" 2>/dev/null || true)"

if [ "$installed_version" != "$FLUTTER_VERSION" ]; then
  echo "Installiere Flutter $FLUTTER_VERSION nach $FLUTTER_HOME ..."
  rm -rf "$FLUTTER_HOME"
  tmp="$(mktemp -d)"
  curl -fsSL --retry 4 "$FLUTTER_URL" -o "$tmp/$FLUTTER_ARCHIVE"
  tar -xJf "$tmp/$FLUTTER_ARCHIVE" -C "$(dirname "$FLUTTER_HOME")"
  rm -rf "$tmp"
  # Das Archiv gehört einem anderen Benutzer; ohne diese Freigabe verweigert git den Zugriff.
  git config --global --add safe.directory "$FLUTTER_HOME"
  "$FLUTTER_HOME/bin/flutter" --version >/dev/null
  echo "$FLUTTER_VERSION" > "$MARKER"
fi

export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$HOME/.pub-cache/bin:$PATH"
if [ -n "${CLAUDE_ENV_FILE:-}" ] && ! grep -qs "$FLUTTER_HOME/bin" "$CLAUDE_ENV_FILE"; then
  echo "export PATH=\"$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:\$HOME/.pub-cache/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

flutter config --no-analytics --no-cli-animations >/dev/null 2>&1 || true
dart --disable-analytics >/dev/null 2>&1 || true

export FLUTTER_SUPPRESS_ANALYTICS=true
cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}"
flutter pub get
dart pub get --directory server
