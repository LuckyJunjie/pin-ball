# Running Tests - Quick Guide

## GUT Installation Status

✅ **GUT is installed** in `addons/gut/`

## Running Tests

### Option 1: Via Godot Editor (Recommended)

1. **Open the project in Godot Editor**
   - Open Godot 4.5
   - Open the project at `/Users/junjiepan/Game/pin-ball`

2. **Enable GUT Plugin**
   - Go to `Project → Project Settings → Plugins`
   - Find "Gut" in the list
   - Check the "Enable" checkbox
   - The GUT panel should appear at the bottom of the editor

3. **Run Tests**
   - In the GUT panel, you'll see test directories
   - Select the tests you want to run:
     - `test/unit/v1.0/` - v1.0 tests
     - `test/unit/v2.0/` - v2.0 tests
     - `test/unit/v3.0/` - v3.0 tests
     - `test/regression/` - Regression tests
     - `test/` - All tests
   - Click "Run All" or "Run Selected"

### Option 2: Via Command Line

#### Prerequisites
You need Godot executable in your PATH or know its location.

**Find Godot on macOS:**
```bash
# Common locations:
/Applications/Godot.app/Contents/MacOS/Godot
~/Applications/Godot.app/Contents/MacOS/Godot
```

**Add to PATH (optional):**
```bash
# Add to ~/.zshrc or ~/.bash_profile
export PATH="$PATH:/Applications/Godot.app/Contents/MacOS"
```

#### Run Tests

**Using the test runner script:**
```bash
cd /Users/junjiepan/Game/pin-ball

# Run all tests
./test/run_tests.sh

# Run specific test directory
./test/run_tests.sh test/unit/v1.0/
./test/run_tests.sh test/unit/v2.0/
./test/run_tests.sh test/unit/v3.0/
./test/run_tests.sh test/regression/

# Run in GUI mode (shows Godot window)
./test/run_tests.sh --gui
```

**Direct Godot command:**
```bash
# If Godot is in PATH
godot --headless --path . -s addons/gut/cli/gut_cmdln.gd -gtest=test/ -gexit

# If Godot is in Applications
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -s addons/gut/cli/gut_cmdln.gd -gtest=test/ -gexit
```

### Option 3: Set Godot Path in Script

Edit `test/run_tests.sh` and add your Godot path:

```bash
# At the top of the script, add:
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
```

Then run:
```bash
./test/run_tests.sh
```

## Test Results

Tests will show:
- ✅ Passed tests
- ❌ Failed tests
- ⚠️ Warnings
- Summary statistics

## Troubleshooting

### "Godot executable not found"
- Install Godot 4.5 from https://godotengine.org/download
- Add it to PATH or edit the test script with the correct path

### "GUT plugin not found"
- GUT should be in `addons/gut/`
- If missing, reinstall GUT (see `test/README.md`)

### "Tests not running"
- Make sure GUT plugin is enabled in Project Settings
- Check that test files are in the correct directories
- Verify test files extend `GutTest`

### "Scene/script errors in tests"
- Some tests may need scene files to exist
- Some tests create instances programmatically
- Check console output for specific errors

## Quick Test Commands

```bash
# All v1.0 tests
./test/run_tests.sh test/unit/v1.0/

# All v2.0 tests  
./test/run_tests.sh test/unit/v2.0/

# All v3.0 tests
./test/run_tests.sh test/unit/v3.0/

# Regression tests (ensures v1.0/v2.0 still work)
./test/run_tests.sh test/regression/

# All tests
./test/run_tests.sh test/
```

## Next Steps

1. **Open Godot Editor** and enable GUT plugin
2. **Run tests via GUT Panel** (easiest method)
3. **Review test results** and fix any failures
4. **Add more tests** as you develop new features
