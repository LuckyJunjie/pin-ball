#!/bin/bash

# Release script for Pin-Ball game
# Archives current version, creates git tag, and exports binaries

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current version from VERSION file
if [ ! -f "VERSION" ]; then
    echo -e "${RED}Error: VERSION file not found!${NC}"
    exit 1
fi

CURRENT_VERSION=$(cat VERSION | tr -d 'v')
NEW_VERSION=""

# Parse command line arguments
if [ "$1" != "" ]; then
    NEW_VERSION="$1"
    # Remove 'v' prefix if present
    NEW_VERSION="${NEW_VERSION#v}"
else
    echo -e "${YELLOW}Usage: ./scripts/release.sh <new_version>${NC}"
    echo -e "${YELLOW}Example: ./scripts/release.sh v0.1.1${NC}"
    exit 1
fi

echo -e "${GREEN}=== Pin-Ball Release Script ===${NC}"
echo -e "Current version: ${CURRENT_VERSION}"
echo -e "New version: ${NEW_VERSION}"
echo ""

# Validate version format (basic check)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format. Use semantic versioning (e.g., 0.1.1)${NC}"
    exit 1
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Warning: git not found. Skipping git operations.${NC}"
    GIT_AVAILABLE=false
else
    GIT_AVAILABLE=true
    # Check if we're in a git repository
    if [ ! -d ".git" ]; then
        echo -e "${YELLOW}Warning: Not a git repository. Skipping git operations.${NC}"
        GIT_AVAILABLE=false
    fi
fi

# Create releases directory structure
RELEASE_DIR="releases/v${NEW_VERSION}"
echo -e "${GREEN}Creating release directory: ${RELEASE_DIR}${NC}"
mkdir -p "${RELEASE_DIR}/source"
mkdir -p "${RELEASE_DIR}/binaries"

# Archive current source code
echo -e "${GREEN}Archiving source code...${NC}"
# Copy source files (exclude build artifacts, releases, etc.)
rsync -av --exclude='releases' \
          --exclude='.git' \
          --exclude='*.import' \
          --exclude='.godot' \
          --exclude='binaries' \
          --exclude='*.tmp' \
          . "${RELEASE_DIR}/source/" || {
    # Fallback to tar if rsync not available
    echo -e "${YELLOW}rsync not available, using tar...${NC}"
    tar --exclude='releases' \
        --exclude='.git' \
        --exclude='*.import' \
        --exclude='.godot' \
        --exclude='binaries' \
        --exclude='*.tmp' \
        -czf "${RELEASE_DIR}/source.tar.gz" . || {
        echo -e "${RED}Error: Failed to archive source code${NC}"
        exit 1
    }
}

# Update VERSION file
echo -e "${GREEN}Updating VERSION file...${NC}"
echo "v${NEW_VERSION}" > VERSION

# Create git tag if git is available
if [ "$GIT_AVAILABLE" = true ]; then
    echo -e "${GREEN}Creating git tag v${NEW_VERSION}...${NC}"
    git add VERSION
    git commit -m "Release v${NEW_VERSION}" || echo -e "${YELLOW}No changes to commit${NC}"
    git tag -a "v${NEW_VERSION}" -m "Release v${NEW_VERSION}" || {
        echo -e "${YELLOW}Tag already exists or failed to create${NC}"
    }
    echo -e "${GREEN}Git tag created. Don't forget to push: git push origin v${NEW_VERSION}${NC}"
fi

# Build binaries if build script exists
if [ -f "scripts/build.sh" ]; then
    echo -e "${GREEN}Building binaries...${NC}"
    chmod +x scripts/build.sh
    ./scripts/build.sh "${NEW_VERSION}" || {
        echo -e "${YELLOW}Warning: Build script failed or not configured${NC}"
    }
else
    echo -e "${YELLOW}Build script not found. Skipping binary export.${NC}"
    echo -e "${YELLOW}Create scripts/build.sh to enable binary exports.${NC}"
fi

echo ""
echo -e "${GREEN}=== Release Complete ===${NC}"
echo -e "Version: v${NEW_VERSION}"
echo -e "Source archive: ${RELEASE_DIR}/source/"
if [ -d "${RELEASE_DIR}/binaries" ] && [ "$(ls -A ${RELEASE_DIR}/binaries)" ]; then
    echo -e "Binaries: ${RELEASE_DIR}/binaries/"
fi
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Test the release"
if [ "$GIT_AVAILABLE" = true ]; then
    echo -e "2. Push git tag: git push origin v${NEW_VERSION}"
fi
echo -e "3. Update CHANGELOG.md and VERSIONS.md with new features"
