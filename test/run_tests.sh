#!/bin/bash

## Test Runner Script for Pinball Game
## This script runs GUT tests using Godot

# ============================================================================
# CONFIGURATION: Set your Godot path here if auto-detection fails
# ============================================================================
# Option 1: Uncomment and set path below (most common on macOS):
# GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
#
# Option 2: Use config file (edit test/godot_path.config)
# Option 3: Set environment variable: export GODOT="/path/to/Godot"
# 
# To find your Godot: ./test/find_godot.sh
# ============================================================================

# Default path (most common macOS location) - uncomment if needed:
# GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"

# Load Godot path from config file if it exists
CONFIG_FILE="$(dirname "${BASH_SOURCE[0]}")/godot_path.config"
if [ -f "$CONFIG_FILE" ]; then
    # Read GODOT_PATH from config file (handle comments and empty lines)
    CONFIG_PATH=$(grep -E "^GODOT_PATH=" "$CONFIG_FILE" | head -1 | cut -d'=' -f2- | tr -d '"' | tr -d "'" | xargs)
    if [ -n "$CONFIG_PATH" ] && [ -f "$CONFIG_PATH" ]; then
        GODOT_PATH="$CONFIG_PATH"
    fi
fi

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get project directory first (needed for some checks)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Pinball Game Test Runner"
echo "======================="
echo ""

# Find Godot executable
GODOT=""

# 1. Check if GODOT environment variable is set
if [ -n "${GODOT}" ] && [ -f "${GODOT}" ]; then
    GODOT="${GODOT}"
# 2. Check if GODOT_PATH is set in script
elif [ -n "${GODOT_PATH}" ] && [ -f "${GODOT_PATH}" ]; then
    GODOT="${GODOT_PATH}"
# 3. Check PATH for godot command
elif command -v godot &> /dev/null; then
    GODOT="godot"
elif command -v godot4 &> /dev/null; then
    GODOT="godot4"
# 4. Try common macOS locations
elif [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
elif [ -f "$HOME/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT="$HOME/Applications/Godot.app/Contents/MacOS/Godot"
# 5. Search in Applications directory
elif [ -d "/Applications" ]; then
    GODOT_FOUND=$(find /Applications -maxdepth 3 -name "Godot" -type f -path "*/Contents/MacOS/Godot" 2>/dev/null | head -1)
    if [ -n "$GODOT_FOUND" ] && [ -f "$GODOT_FOUND" ]; then
        GODOT="$GODOT_FOUND"
    fi
# 6. Try project directory (if Godot is bundled with project)
elif [ -f "$PROJECT_DIR/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT="$PROJECT_DIR/Godot.app/Contents/MacOS/Godot"
fi

# Final check - if still not found, provide helpful error
if [ -z "$GODOT" ] || [ ! -f "$GODOT" ]; then
    echo -e "${RED}Error: Godot executable not found!${NC}"
    echo ""
    echo "Please set your Godot path using one of these methods:"
    echo ""
    echo "Method 1: Set environment variable (recommended)"
    echo "  export GODOT=\"/path/to/Godot.app/Contents/MacOS/Godot\""
    echo "  ./test/run_tests.sh"
    echo ""
    echo "Method 2: Edit this script"
    echo "  Open test/run_tests.sh and uncomment/set GODOT_PATH at the top"
    echo ""
    echo "Method 3: Add Godot to PATH"
    echo "  Add to ~/.zshrc: export PATH=\"\$PATH:/Applications/Godot.app/Contents/MacOS\""
    echo ""
    echo "Download Godot 4.5 from: https://godotengine.org/download"
    exit 1
fi

echo -e "${GREEN}Found Godot: $GODOT${NC}"
echo ""

# Change to project directory
cd "$PROJECT_DIR"

# Check if GUT is installed
if [ ! -d "addons/gut" ]; then
    echo -e "${RED}Error: GUT plugin not found in addons/gut${NC}"
    echo "Please install GUT first (see test/README.md)"
    exit 1
fi

# Parse command line arguments
TEST_PATH="test/"
RUN_MODE="headless"

if [ "$1" == "--gui" ] || [ "$1" == "-g" ]; then
    RUN_MODE="gui"
    shift
fi

if [ -n "$1" ]; then
    TEST_PATH="$1"
fi

echo -e "${YELLOW}Running tests from: $TEST_PATH${NC}"
echo ""

# Run tests
if [ "$RUN_MODE" == "headless" ]; then
    echo "Running in headless mode..."
    echo ""
    $GODOT --headless --path "$PROJECT_DIR" -s addons/gut/cli/gut_cmdln.gd -gtest="$TEST_PATH" -gexit
else
    echo "Running in GUI mode..."
    echo ""
    $GODOT --path "$PROJECT_DIR" -s addons/gut/cli/gut_cmdln.gd -gtest="$TEST_PATH"
fi

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Tests completed successfully!${NC}"
else
    echo -e "${RED}✗ Tests failed with exit code: $EXIT_CODE${NC}"
fi

exit $EXIT_CODE
