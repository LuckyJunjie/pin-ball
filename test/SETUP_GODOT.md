# Setting Up Godot Path for Tests

## Quick Setup

### Option 1: Auto-Detect (Recommended)
Run the helper script to find and set Godot automatically:
```bash
./test/find_godot.sh
```

### Option 2: Manual Setup
Edit `test/godot_path.config` and set your Godot path:

```bash
# Open the config file
nano test/godot_path.config

# Or edit with your preferred editor
# Set GODOT_PATH to your Godot executable path, for example:
GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
```

### Option 3: Environment Variable
Set it in your shell session:
```bash
export GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
./test/run_tests.sh
```

### Option 4: Edit Script Directly
Edit `test/run_tests.sh` and uncomment/set the `GODOT_PATH` variable at the top.

## Finding Your Godot Installation

**On macOS:**
- Usually in `/Applications/Godot.app/Contents/MacOS/Godot`
- Or `~/Applications/Godot.app/Contents/MacOS/Godot`

**Check if installed:**
```bash
ls -la /Applications/ | grep -i godot
```

**If not installed:**
Download from: https://godotengine.org/download

## Verify Setup

After setting the path, test it:
```bash
./test/run_tests.sh test/unit/v1.0/test_ball.gd
```

If it works, you'll see "Found Godot: [path]" message.
