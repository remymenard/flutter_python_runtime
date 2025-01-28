#!/bin/bash
set -e

echo "Starting micromamba download..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MICROMAMBA_DIR="$SCRIPT_DIR/Resources/micromamba"
echo "Download directory: $MICROMAMBA_DIR"

mkdir -p "$MICROMAMBA_DIR/bin"
echo "Created directory structure"

echo "Downloading micromamba..."
curl -L "https://micro.mamba.pm/api/micromamba/osx-arm64/latest" | tar xvj -C "$MICROMAMBA_DIR" bin/micromamba

if [ -f "$MICROMAMBA_DIR/bin/micromamba" ]; then
    echo "Micromamba binary found"
    chmod +x "$MICROMAMBA_DIR/bin/micromamba"
    echo "Made micromamba executable"
else
    echo "Error: Micromamba binary not found!"
    ls -la "$MICROMAMBA_DIR/bin"
    exit 1
fi

# echo "Cleaning up extra files..."
# find "$MICROMAMBA_DIR" -mindepth 1 ! -regex "^$MICROMAMBA_DIR/bin\\(/.*\\)?$" -delete

# echo "Final directory structure:"
# ls -R "$MICROMAMBA_DIR" 