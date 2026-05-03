#!/usr/bin/env bash
set -euo pipefail

if ! command -v ngrok >/dev/null 2>&1; then
  cat <<'EOF'
ngrok is not installed.

Arch/CachyOS:
  sudo pacman -S ngrok

If the pacman package is not available:
  yay -S ngrok

Or download ngrok from:
  https://ngrok.com/download

After installing, configure your token:
  ngrok config add-authtoken YOUR_TOKEN
EOF
  exit 1
fi

adminer_reachable=false

if command -v curl >/dev/null 2>&1; then
  if curl -fsS --max-time 5 http://localhost:8080 >/dev/null 2>&1; then
    adminer_reachable=true
  fi
else
  if timeout 5 bash -c '</dev/tcp/127.0.0.1/8080' >/dev/null 2>&1; then
    adminer_reachable=true
  fi
fi

if [ "$adminer_reachable" != "true" ]; then
  echo "Run docker compose up -d first"
  exit 1
fi

echo "This exposes the Adminer login page publicly. Use only during the workshop and stop ngrok after the session."
exec ngrok http 8080
