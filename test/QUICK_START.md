# Quick Start - Running Tests

## Step 1: Set Godot Path

**Easiest way:** Run the auto-detection script:
```bash
cd /Users/junjiepan/Game/pin-ball
./test/find_godot.sh
```

**Manual way:** Edit `test/godot_path.config`:
```bash
nano test/godot_path.config
# Set: GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
```

## Step 2: Run Tests

```bash
# All tests
./test/run_tests.sh

# Specific test suite
./test/run_tests.sh test/unit/v1.0/
./test/run_tests.sh test/unit/v2.0/
./test/run_tests.sh test/unit/v3.0/
```

## Alternative: Use Godot Editor

1. Open project in Godot Editor
2. Enable GUT plugin (Project → Settings → Plugins)
3. Use GUT Panel to run tests

## Troubleshooting

**"Godot executable not found"**
- Run: `./test/find_godot.sh` to auto-detect
- Or manually set path in `test/godot_path.config`

**"GUT plugin not found"**
- GUT is already installed in `addons/gut/`
- Enable it in Project Settings → Plugins

For more details, see `test/SETUP_GODOT.md`
