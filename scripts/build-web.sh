#!/bin/bash
set -e

FLUTTER_VERSION="3.24.3"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo "=== Installing Flutter ${FLUTTER_VERSION} ==="
curl -sL "$FLUTTER_URL" | tar xJ -C /tmp
export PATH="/tmp/flutter/bin:$PATH"

echo "=== Flutter version ==="
flutter --version

echo "=== Getting dependencies ==="
cd app
flutter pub get

echo "=== Building web ==="
flutter build web --release --web-renderer canvaskit

echo "=== Build complete ==="
ls -la build/web/
