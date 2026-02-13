extends SceneTree

## Test Runner Script
## Can be used to run tests from command line or as a scene
## Usage: godot --headless --path . -s test/run_tests.gd

func _init():
	# GUT is the test framework. Run from project root (godot must be in PATH):
	#   godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=test/v4/unit/ -gexit
	print("To run tests, use GUT:")
	print("  - Via GUT Panel in editor (test/v4/unit/ or test/v4/)")
	print("  - Via command line (from project root, godot in PATH):")
	print("    godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=test/v4/unit/ -gexit")
	quit()
