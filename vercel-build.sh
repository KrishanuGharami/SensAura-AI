#!/usr/bin/env bash
set -e

echo "===================================================="
echo "  SensAura AI - Vercel Cloud Build Pipeline        "
echo "===================================================="

# Ensure git trusts directory in container environments
git config --global --add safe.directory "*" || true

# 1. Locate or install Flutter SDK
if ! command -v flutter &> /dev/null; then
  echo "[-] Flutter command not found in PATH."
  if [ ! -d "$HOME/flutter" ] && [ ! -d "flutter" ]; then
    echo "[+] Cloning Flutter stable SDK (depth 1)..."
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
    export PATH="$HOME/flutter/bin:$PATH"
  elif [ -d "$HOME/flutter" ]; then
    echo "[*] Using cached Flutter SDK in $HOME/flutter..."
    export PATH="$HOME/flutter/bin:$PATH"
  elif [ -d "flutter" ]; then
    echo "[*] Using local workspace flutter directory..."
    export PATH="$(pwd)/flutter/bin:$PATH"
  fi
else
  echo "[*] Using system Flutter: $(which flutter)"
fi

echo "[+] Flutter Environment:"
flutter config --no-analytics
flutter --version

# 2. Pre-cache web engine artifacts
echo "[+] Pre-caching Flutter Web engine..."
flutter precache --web

# 3. Fetch dependencies
echo "[+] Fetching Flutter packages..."
flutter pub get

# 4. Build Web Release bundle
echo "[+] Compiling Flutter Web release bundle..."
flutter build web --release

# 5. Ensure vercel.json is present inside output directory for SPA support
if [ -f "vercel.json" ]; then
  cp vercel.json build/web/
fi

echo "===================================================="
echo "  SensAura AI - Web Build Successful!               "
echo "  Output generated at: build/web                    "
echo "===================================================="
