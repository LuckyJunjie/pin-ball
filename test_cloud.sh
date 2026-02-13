#!/bin/bash
# Pinball Game - Cloud Test Launcher
# Usage: ./test_cloud.sh [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🎮 Pinball Game - Cloud Test"
echo "=============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for Godot
check_godot() {
    if ! command -v godot &> /dev/null; then
        echo -e "${RED}❌ Godot not found!${NC}"
        echo "Run: bash .devcontainer/setup.sh"
        exit 1
    fi
    
    if ! command -v godot_headless &> /dev/null; then
        echo -e "${RED}❌ Godot Headless not found!${NC}"
        echo "Run: bash .devcontainer/setup.sh"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Godot found: $(godot --version)${NC}"
}

# Quick syntax check
check_syntax() {
    echo ""
    echo "📝 Checking GDScript syntax..."
    
    errors=0
    
    # Check for common issues
    for file in $(find . -name "*.gd" -type f 2>/dev/null); do
        # Check for unclosed brackets
        if grep -q 'func.*(' "$file" && ! grep -q ')' "$file" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Potential bracket issue: $file${NC}"
            ((errors++))
        fi
        
        # Check for unclosed braces
        if grep -q '{' "$file" && ! grep -q '}' "$file" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Potential brace issue: $file${NC}"
            ((errors++))
        fi
    done
    
    # Count scripts
    script_count=$(find . -name "*.gd" | wc -l)
    echo -e "${GREEN}✅ Found $script_count GDScript files${NC}"
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✅ Syntax check passed${NC}"
    else
        echo -e "${YELLOW}⚠️ $errors potential issues found${NC}"
    fi
}

# Run Godot headless test
run_headless_test() {
    echo ""
    echo "🧪 Running headless test..."
    
    if godot_headless --path "$SCRIPT_DIR" --quiet --headless 2>&1; then
        echo -e "${GREEN}✅ Godot project loaded successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Godot project failed to load${NC}"
        return 1
    fi
}

# Export to web (if configured)
export_web() {
    echo ""
    echo "🌐 Exporting to Web..."
    
    mkdir -p build/web
    
    if godot --headless --export-release "Web" build/web/index.html 2>&1; then
        echo -e "${GREEN}✅ Web export successful${NC}"
        echo "📁 Output: build/web/"
        return 0
    else
        echo -e "${YELLOW}⚠️ Web export failed (expected if export_presets.cfg missing)${NC}"
        return 1
    fi
}

# Show project status
show_status() {
    echo ""
    echo "📊 Project Status:"
    echo "   Scripts: $(find . -name '*.gd' | wc -l)"
    echo "   Scenes:  $(find . -name '*.tscn' | wc -l)"
    echo "   Assets:  $(find . -name '*.png' -o -name '*.jpg' -o -name '*.wav' -o -name '*.ogg' 2>/dev/null | wc -l)"
    
    # Git status
    if [ -d .git ]; then
        echo ""
        echo "📝 Git Status:"
        git status --short 2>/dev/null | head -5
    fi
}

# Main menu
case "${1:-test}" in
    test)
        check_godot
        check_syntax
        run_headless_test
        show_status
        ;;
    syntax)
        check_godot
        check_syntax
        ;;
    headless)
        check_godot
        run_headless_test
        ;;
    export)
        check_godot
        export_web
        ;;
    status)
        show_status
        ;;
    help|-h|--help)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  test      - Full test (default)"
        echo "  syntax    - Check GDScript syntax only"
        echo "  headless  - Run Godot headless test only"
        echo "  export    - Export to Web"
        echo "  status    - Show project status"
        echo "  help      - Show this help"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run: $0 help"
        exit 1
        ;;
esac

echo ""
echo "✨ Done!"
