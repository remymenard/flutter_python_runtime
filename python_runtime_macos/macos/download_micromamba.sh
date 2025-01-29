#!/bin/bash
set -e

echo "Setting up micromamba..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ASSETS_DIR="$SCRIPT_DIR/../../assets"
MICROMAMBA_PATH="$ASSETS_DIR/micromamba"

if [ -f "$MICROMAMBA_PATH" ]; then
    echo "Micromamba binary found"
    chmod +x "$MICROMAMBA_PATH"
    echo "Made micromamba executable"
else
    echo "Error: Micromamba binary not found at $MICROMAMBA_PATH!"
    ls -la "$ASSETS_DIR"
    exit 1
fi

# echo "Cleaning up extra files..."
# find "$MICROMAMBA_DIR" -mindepth 1 ! -regex "^$MICROMAMBA_DIR/bin\\(/.*\\)?$" -delete

# echo "Final directory structure:"
# ls -R "$MICROMAMBA_DIR" 