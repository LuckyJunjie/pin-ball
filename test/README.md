

# Pinball Game Test Suite

This directory contains comprehensive tests for the Pinball game using GUT (Godot Unit Test) framework.

## Installation

### ✅ GUT is Already Installed

GUT has been installed in `addons/gut/`. To activate:

1. **Open Godot Editor**
2. **Go to Project → Project Settings → Plugins**
3. **Find "Gut" in the list and enable it**
4. **GUT Panel will appear at the bottom of the editor**

For detailed instructions on running tests, see **[RUN_TESTS.md](RUN_TESTS.md)**.

### Manual Installation (if needed)

1. **Via Godot Asset Library:**
   - Open Godot Editor
   - Click the "AssetLib" button at the top
   - Search for "Gut"
   - Click "Install" and follow the prompts
   - Go to Project → Project Settings → Plugins tab
   - Activate GUT plugin

2. **Manual Download:**
   - Download GUT from: https://github.com/bitwes/Gut/releases
   - Extract the `gut` folder to `addons/gut/` in your project
   - Go to Project → Project Settings → Plugins tab
   - Activate GUT plugin

## Test Structure

```
test/
├── unit/              # Unit tests for individual components
│   ├── v1.0/         # v1.0 core mechanics tests
│   ├── v2.0/         # v2.0 monetization tests
│   └── v3.0/         # v3.0 feature tests
├── integration/       # Integration tests
│   ├── v1.0/         # v1.0 integration tests
│   ├── v2.0/         # v2.0 integration tests
│   └── v3.0/         # v3.0 integration tests
└── regression/        # Regression tests to prevent breakage
```

## Running Tests

**📖 For detailed instructions, see [RUN_TESTS.md](RUN_TESTS.md)**

### Quick Start

**Via Godot Editor (Easiest):**
1. Open project in Godot Editor
2. Enable GUT plugin (Project → Settings → Plugins)
3. Open GUT Panel (bottom of editor)
4. Select test directories and click "Run All"

**Via Command Line:**
```bash
# Use the test runner script
./test/run_tests.sh

# Or directly with Godot
godot --headless --path . -s addons/gut/cli/gut_cmdln.gd -gtest=test/ -gexit
```

### Running Specific Test Suites
- **v1.0 Tests:** `./test/run_tests.sh test/unit/v1.0/`
- **v2.0 Tests:** `./test/run_tests.sh test/unit/v2.0/`
- **v3.0 Tests:** `./test/run_tests.sh test/unit/v3.0/`
- **Regression Tests:** `./test/run_tests.sh test/regression/`

## Test Coverage

### v1.0 Tests (Core Mechanics)
- Ball physics and movement
- Flipper controls and physics
- Launcher system
- Obstacle collisions and scoring
- Ball queue management
- Maze pipe system
- Hold system

### v2.0 Tests (Monetization)
- Currency system (coins/gems)
- Shop functionality
- Item database
- Save/load system
- Equipped items
- Battle pass (if implemented)

### v3.0 Tests (Enhanced Features)
- Skill shot system
- Multiball mode
- Dynamic multiplier system
- Combo system
- Enhanced physics
- Animation system
- Particle effects
- Enhanced audio

## Writing New Tests

All tests should extend `GutTest` class. Example:

```gdscript
extends GutTest

func test_example():
    var instance = preload("res://scripts/Example.gd").new()
    assert_not_null(instance, "Instance should be created")
    assert_eq(instance.some_value, expected_value)
```

## Continuous Integration

Tests can be integrated into CI/CD pipelines using the command line interface.
