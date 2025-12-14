#!/bin/bash

# Build script for Pin-Ball game
# Exports binaries for different platforms using Godot

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

VERSION="${1:-unknown}"
RELEASE_DIR="releases/v${VERSION}/binaries"

if [ "$VERSION" = "unknown" ]; then
    echo -e "${YELLOW}Warning: No version specified. Using 'unknown'${NC}"
fi

# Check if Godot is available
if ! command -v godot &> /dev/null; then
    echo -e "${RED}Error: Godot not found in PATH${NC}"
    echo -e "${YELLOW}Please install Godot 4.5 and add it to your PATH${NC}"
    echo -e "${YELLOW}Or specify Godot path: GODOT_PATH=/path/to/godot ./scripts/build.sh${NC}"
    exit 1
fi

GODOT_CMD="${GODOT_PATH:-godot}"

# Check if export_presets.cfg exists
if [ ! -f "export_presets.cfg" ]; then
    echo -e "${YELLOW}Warning: export_presets.cfg not found${NC}"
    echo -e "${YELLOW}Please create export presets in Godot Editor (Project → Export)${NC}"
    exit 1
fi

echo -e "${GREEN}=== Building Pin-Ball v${VERSION} ===${NC}"
echo -e "Using Godot: ${GODOT_CMD}"
echo ""

# Create binaries directory
mkdir -p "${RELEASE_DIR}"

# Export for each preset in export_presets.cfg
# This is a simplified version - in practice, you'd parse export_presets.cfg
# For now, we'll try common export names

PLATFORMS=("Linux/X11" "macOS" "Windows Desktop")

for platform in "${PLATFORMS[@]}"; do
    echo -e "${GREEN}Attempting to export for ${platform}...${NC}"
    
    # Try to export (this will fail if preset doesn't exist, which is fine)
    $GODOT_CMD --headless --export-release "${platform}" "${RELEASE_DIR}/pinball-${platform//\//-}-v${VERSION}" 2>/dev/null || {
        echo -e "${YELLOW}  Preset '${platform}' not found or export failed. Skipping.${NC}"
    }
done

# Alternative: Export using preset names directly
# You can customize this based on your actual export preset names
echo ""
echo -e "${GREEN}To export manually:${NC}"
echo -e "1. Open project in Godot Editor"
echo -e "2. Go to Project → Export"
echo -e "3. Select your platform and click 'Export Project'"
echo -e "4. Save to: ${RELEASE_DIR}/"

echo ""
echo -e "${GREEN}Build script complete.${NC}"
echo -e "Binaries directory: ${RELEASE_DIR}/"
