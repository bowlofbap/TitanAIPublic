#!/bin/sh
set -e

echo "📁 Checking Packages folder contents:"
ls -al Packages || {
  echo "❌ Packages folder not found!"
  exit 1
}

echo "📄 Checking if Packages/TestEZ.lua exists:"
if [ -f "Packages/TestEZ.lua" ]; then
  echo "✅ Packages/TestEZ.lua exists."
else
  echo "❌ Packages/TestEZ.lua does NOT exist."
  echo "🛠 Contents of Packages for reference:"
  find Packages -type f
  exit 1
fi

$HOME/.aftman/bin/rojo build "$1" --output dist.rbxl
python3 scripts/python/upload_and_run_task.py dist.rbxl "$2"
rm dist.rbxl