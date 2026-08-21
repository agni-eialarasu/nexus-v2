#!/bin/bash
set -e

FLUTTER_VERSION="3.47.1"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_HOME="/tmp/flutter"

echo "=== Installing Flutter ${FLUTTER_VERSION} ==="
if [ ! -d "$FLUTTER_HOME" ]; then
  curl -sL "$FLUTTER_URL" -o /tmp/flutter.tar.xz
  tar xJf /tmp/flutter.tar.xz -C /tmp
  rm -f /tmp/flutter.tar.xz
fi

# Force our Flutter/Dart to be first in PATH
export PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:$PATH"

echo "=== Flutter version ==="
flutter --version
echo "=== Dart version ==="
dart --version
echo "=== Which flutter ==="
which flutter
which dart

echo "=== Disabling analytics ==="
flutter config --no-analytics 2>/dev/null || true
dart --disable-analytics 2>/dev/null || true

echo "=== Getting dependencies ==="
cd app
"${FLUTTER_HOME}/bin/flutter" pub get

echo "=== Building web ==="
"${FLUTTER_HOME}/bin/flutter" build web --release --web-renderer canvaskit

echo "=== Build complete ==="
ls -la build/web/
