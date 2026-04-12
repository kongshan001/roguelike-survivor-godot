#!/bin/bash
# Run automated tests for Survivor Arena using GUT
# Usage: ./run_tests.sh [path_to_godot]
#
# If no path is provided, it tries common locations:
#   - macOS: /Applications/Godot.app
#   - Linux: godot in PATH

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Find Godot executable
if [ -n "$1" ]; then
    GODOT="$1"
elif [ -x "$(command -v godot)" ]; then
    GODOT="godot"
elif [ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
else
    echo "Error: Godot executable not found."
    echo "Usage: $0 [path_to_godot_executable]"
    exit 1
fi

echo "=== Running Survivor Arena Tests ==="
echo "Godot: $GODOT"
echo "Project: $SCRIPT_DIR"
echo ""

mkdir -p "$SCRIPT_DIR/test"

# Run GUT tests headlessly - uses .gutconfig.json for configuration
"$GODOT" --headless --path "$SCRIPT_DIR" \
    -s addons/gut/gut_cmdln.gd \
    -gexit \
    "$@"

echo ""
echo "=== Tests Complete ==="
