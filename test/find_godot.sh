#!/bin/bash

## Helper script to find and set Godot path

echo "Searching for Godot installation..."
echo ""

# Try to find Godot
FOUND_PATHS=()

# Check PATH
if command -v godot &> /dev/null; then
    FOUND_PATHS+=("$(which godot) (from PATH)")
fi

if command -v godot4 &> /dev/null; then
    FOUND_PATHS+=("$(which godot4) (from PATH)")
fi

# Check common locations
COMMON_PATHS=(
    "/Applications/Godot.app/Contents/MacOS/Godot"
    "$HOME/Applications/Godot.app/Contents/MacOS/Godot"
)

for path in "${COMMON_PATHS[@]}"; do
    if [ -f "$path" ]; then
        FOUND_PATHS+=("$path")
    fi
done

# Search in Applications
if [ -d "/Applications" ]; then
    while IFS= read -r path; do
        if [ -f "$path" ]; then
            FOUND_PATHS+=("$path")
        fi
    done < <(find /Applications -maxdepth 3 -name "Godot" -type f -path "*/Contents/MacOS/Godot" 2>/dev/null)
fi

# Display results
if [ ${#FOUND_PATHS[@]} -eq 0 ]; then
    echo "❌ No Godot installation found!"
    echo ""
    echo "Please:"
    echo "1. Install Godot 4.5 from https://godotengine.org/download"
    echo "2. Or manually set the path in test/godot_path.config"
    exit 1
else
    echo "✅ Found ${#FOUND_PATHS[@]} Godot installation(s):"
    echo ""
    for i in "${!FOUND_PATHS[@]}"; do
        echo "  $((i+1)). ${FOUND_PATHS[$i]}"
    done
    echo ""
    
    # Use first found path
    SELECTED_PATH="${FOUND_PATHS[0]%% *}"  # Remove "(from PATH)" suffix if present
    if [[ "$SELECTED_PATH" == *"("* ]]; then
        SELECTED_PATH=$(echo "$SELECTED_PATH" | awk '{print $1}')
    fi
    
    echo "Using: $SELECTED_PATH"
    echo ""
    
    # Update config file
    CONFIG_FILE="$(dirname "${BASH_SOURCE[0]}")/godot_path.config"
    if [ -f "$CONFIG_FILE" ]; then
        # Update the config file
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^GODOT_PATH=.*|GODOT_PATH=\"$SELECTED_PATH\"|" "$CONFIG_FILE"
        else
            sed -i "s|^GODOT_PATH=.*|GODOT_PATH=\"$SELECTED_PATH\"|" "$CONFIG_FILE"
        fi
        echo "✅ Updated $CONFIG_FILE"
        echo ""
        echo "You can now run tests with: ./test/run_tests.sh"
    else
        echo "To use this path, add to test/godot_path.config:"
        echo "GODOT_PATH=\"$SELECTED_PATH\""
    fi
fi
