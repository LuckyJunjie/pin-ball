extends SceneTree

## Test Runner Script
## Can be used to run tests from command line or as a scene
## Usage: godot --headless --path . -s test/run_tests.gd

func _init():
	# This script can be used to run tests programmatically
	# For GUT, use the GUT panel or command line:
	# godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=test/
	print("To run tests, use GUT:")
	print("  - Via GUT Panel in editor")
	print("  - Via command line: godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=test/")
	quit()
