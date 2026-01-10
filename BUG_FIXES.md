# Bug Fixes Documentation

**Date:** 2024-12-19  
**Purpose:** Document all bugs found during runtime testing and their fixes

---

## Bug 1: Input Event API Error - is_action_just_pressed() doesn't exist

**Root Cause:**  
In Godot 4.5, `InputEvent` objects do not have the `is_action_just_pressed()` method. This method only exists on the `Input` singleton, not on `InputEvent` objects. Additionally, `InputEventKey` doesn't have `is_action_pressed()` method either - the correct methods are `is_action()` to check if the event matches an action, and `pressed` property to check if it's a press event.

**Error Message:**
```
Invalid call. Nonexistent function 'is_action_just_pressed' in base 'InputEventKey'.
```

**Solution:**  
Use `event.is_action("action_name")` combined with `event.pressed` to check if the action is pressed. Add `not event.is_echo()` to ignore key repeat events for "just pressed" behavior.

**Code Change:**
```gdscript
# Before:
func _input(event):
	if not event is InputEventKey:
		return
	if event.is_action_pressed("ui_cancel"):  # Esc key
		toggle_pause()
	if event.is_action_just_pressed("ui_down"):  # Down Arrow - release ball from queue
		release_ball_from_queue()

# After:
func _input(event):
	# Only process key events (ignore mouse movement, etc.)
	if not event is InputEventKey:
		return
	
	if event.is_action("ui_cancel") and event.pressed:  # Esc key
		toggle_pause()
	if event.is_action("ui_down") and event.pressed and not event.is_echo():  # Down Arrow - release ball from queue (just pressed, not held)
		release_ball_from_queue()
```

**File:** `scripts/GameManager.gd` (lines 118-126)  
**Time:** 2024-12-19  
**Status:** ✅ FIXED

---

## Bug 2: Ternary Operator Type Compatibility Error

**Root Cause:**  
Ternary operator requires both branches to return compatible types. The expression `get_parent().get_children() if get_parent() else "No parent"` returns an Array in the true branch and a String in the false branch, which are incompatible types in GDScript's strict typing.

**Error Message:**
```
GDScript::reload: Values of the ternary operator are not mutually compatible.
```

**Solution:**  
Convert the array to string explicitly before using in the ternary operator, or separate the logic into an if-else statement with explicit string conversion.

**Code Change:**
```gdscript
# Before:
print("[GameManager] Available children of parent: ", get_parent().get_children() if get_parent() else "No parent")

# After:
var parent_info = str(get_parent().get_children()) if get_parent() else "No parent"
print("[GameManager] Available children of parent: ", parent_info)
```

**File:** `scripts/GameManager.gd` (lines 41, 53)  
**Time:** 2024-12-19  
**Status:** ✅ FIXED

---

## Bug 3-9: Invalid UID Warnings in Scene Files

**Root Cause:**  
Scene files contain texture UID references that don't match Godot's actual resource UIDs. This happens when resources are imported or when scene files are edited outside the Godot editor. Godot handles this gracefully by falling back to text paths, but generates warnings.

**Error Message:**
```
ext_resource, invalid UID 'uid://ball_texture' in 'res://scenes/Ball.tscn:4', using text path instead
ext_resource, invalid UID 'uid://flipper_texture' in 'res://scenes/Flipper.tscn:4', using text path instead
ext_resource, invalid UID 'uid://bumper_texture' in 'res://scenes/Obstacle.tscn:4', using text path instead
ext_resource, invalid UID 'uid://background_texture' in 'res://scenes/Main.tscn:11', using text path instead
ext_resource, invalid UID 'uid://wall_texture' in 'res://scenes/Main.tscn:12', using text path instead
ext_resource, invalid UID 'uid://c8rxcg34eqt8x' in 'res://scenes/Launcher.tscn:4', using text path instead
ext_resource, invalid UID 'uid://snj1hfeho14a' in 'res://scenes/Launcher.tscn:5', using text path instead
```

**Affected Files:**
- `scenes/Ball.tscn` (line 4: ball_texture)
- `scenes/Flipper.tscn` (line 4: flipper_texture)
- `scenes/Obstacle.tscn` (line 4: bumper_texture)
- `scenes/Main.tscn` (lines 11-12: background_texture, wall_texture)
- `scenes/Launcher.tscn` (lines 4-5: plunger texture, launcher_base texture)

**Solution:**  
These are warnings, not errors. Godot handles them gracefully by using the text path. To properly fix:
1. Open each scene file in Godot Editor
2. Reassign the texture resources in the Inspector
3. Godot will regenerate correct UIDs automatically

**Alternative Solution (if needed):**  
Remove the UID references and use only text paths. However, UIDs are preferred for better resource management.

**Time:** 2024-12-19  
**Status:** ⚠️ WARNING (Non-critical - Godot handles gracefully)

**Note:** These warnings don't prevent the game from running. They can be fixed by reassigning resources in the Godot editor when convenient.

---

## Bug 10: Ball Cannot Fall Through Bottom Boundary

**Root Cause:**  
The Ball.gd script has boundary clamping code in `_physics_process()` that prevents the ball from going below `boundary_bottom` (650.0). The clamping code pushes the ball back up if it goes below this threshold, preventing the ball from falling through the bottom gap between the left and right bottom walls to end the current ball's game.

**Solution:**  
Modified the boundary clamping to only enforce horizontal boundaries and top boundary, but allow the ball to fall through the bottom boundary. Removed the bottom Y clamping check so the ball can fall below the playfield and trigger the ball_lost signal.

**Code Change:**
```gdscript
# Before:
# Ensure ball stays within boundaries (safety check)
var clamped_x = clamp(global_position.x, boundary_left, boundary_right)
var clamped_y = clamp(global_position.y, boundary_top, boundary_bottom)

# If ball somehow escaped, push it back in
if global_position.x != clamped_x or global_position.y != clamped_y:
	global_position = Vector2(clamped_x, clamped_y)
	# ... boundary correction code including bottom
	if global_position.y >= boundary_bottom:
		apply_impulse(Vector2(0, -50))

# After:
# Ensure ball stays within horizontal boundaries (safety check)
# Allow ball to fall through bottom boundary to end game
var clamped_x = clamp(global_position.x, boundary_left, boundary_right)

# Only clamp Y if above bottom boundary (allow fall-through below)
var clamped_y = global_position.y
if global_position.y < boundary_top:
	clamped_y = boundary_top
# Don't clamp Y at bottom - allow ball to fall through

# If ball escaped horizontally or vertically (top only), push it back
if global_position.x != clamped_x or (global_position.y < boundary_top and global_position.y != clamped_y):
	global_position = Vector2(clamped_x, clamped_y)
	# ... boundary correction code (no bottom clamping)
```

**File:** `scripts/Ball.gd` (lines 69-97)  
**Time:** 2024-12-19  
**Status:** ✅ FIXED

**Note:** The bottom walls (WallBottomLeft and WallBottomRight) in Main.tscn are positioned to leave a gap in the middle (approximately x: 350-550), allowing the ball to fall through. The boundary clamping code was preventing this by forcing the ball back up.

---

## Bug 11: Background Image Not Displaying

**Root Cause:**  
The Background node in Main.tscn was configured as a ColorRect with a solid color instead of using the background.png texture file. The background.png file exists but was not being used.

**Solution:**  
Changed the Background node from ColorRect to Sprite2D and configured it to use the background.png texture. Added the background texture as an ExtResource and positioned the sprite at the center of the playfield (400, 300).

**Code Change:**
```gdscript
# Before:
[node name="Background" type="ColorRect" parent="Playfield"]
visible = true
offset_right = 800.0
offset_bottom = 600.0
color = Color(0.1, 0.1, 0.2, 1)

# After:
[node name="Background" type="Sprite2D" parent="Playfield"]
texture = ExtResource("11_background_texture")
offset = Vector2(400, 300)
```

**File:** `scenes/Main.tscn` (lines 58-60, added ExtResource line 12)  
**Time:** 2024-12-19  
**Status:** ✅ FIXED

**Note:** The background.png texture is centered at (400, 300) to match the playfield dimensions (800x600). The Sprite2D will automatically scale to display the texture at its native size.

---

## Summary

| Bug ID | Severity | Status | File | Lines |
|--------|----------|--------|------|-------|
| Bug 1 | Critical (Error) | ✅ FIXED | scripts/GameManager.gd | 118-126 |
| Bug 2 | Critical (Error) | ✅ FIXED | scripts/GameManager.gd | 41, 54 |
| Bug 3-9 | Warning | ⚠️ NON-CRITICAL | Multiple .tscn files | Various |
| Bug 10 | Gameplay Bug | ✅ FIXED | scripts/Ball.gd | 69-97 |
| Bug 11 | Visual Bug | ✅ FIXED | scenes/Main.tscn | 58-60, 12 |
| Bug 12 | Critical (Parse Error) | ✅ FIXED | scenes/Main.tscn | 262, 266, 270, 274 |

**Total Bugs Fixed:** 5 bugs (4 critical/gameplay, 1 visual)  
**Total Warnings:** 7 (non-critical, handled gracefully by Godot)

---

## Testing Status

- ✅ Bug 1: Fixed and verified - using correct Godot 4.5 InputEvent API (`is_action()` + `pressed` property)
- ✅ Bug 2: Fixed and verified - ternary operator now type-compatible
- ⚠️ Bug 3-9: Warnings remain but don't affect functionality
- ✅ Bug 10: Fixed and verified - ball can now fall through bottom boundary to end game
- ✅ Bug 11: Fixed and verified - background.png texture now displays correctly
- ✅ Bug 12: Fixed and verified - all ExtResource references updated, scene loads without parse errors

**Recommendation:** All critical errors have been fixed. The UID warnings can be addressed later by reassigning resources in the Godot editor, but they don't prevent the game from running.

---

---

## Bug 12: Parse Error in Main.tscn - Invalid ExtResource Reference

**Root Cause:**  
After adding the background texture resource (id="11"), the Hold scene resource ID was changed from "11" to "12". However, some Hold node instances (Hold2, Hold3, Hold4, Hold5) still referenced the old ExtResource("11_hold_scene") instead of the new ExtResource("12_hold_scene"), causing a parse error when Godot tried to load the scene.

**Error Message:**
```
ERROR: scene/resources/resource_format_text.cpp:279 - Parse Error: Parse error. [Resource file res://scenes/Main.tscn:262]
ERROR: Failed loading resource: res://scenes/Main.tscn.
```

**Solution:**  
Updated all remaining Hold scene references from ExtResource("11_hold_scene") to ExtResource("12_hold_scene") to match the new resource ID assigned when the background texture was added.

**Code Change:**
```gdscript
# Before:
[node name="Hold2" parent="Playfield/Holds" instance=ExtResource("11_hold_scene")]
[node name="Hold3" parent="Playfield/Holds" instance=ExtResource("11_hold_scene")]
[node name="Hold4" parent="Playfield/Holds" instance=ExtResource("11_hold_scene")]
[node name="Hold5" parent="Playfield/Holds" instance=ExtResource("11_hold_scene")]

# After:
[node name="Hold2" parent="Playfield/Holds" instance=ExtResource("12_hold_scene")]
[node name="Hold3" parent="Playfield/Holds" instance=ExtResource("12_hold_scene")]
[node name="Hold4" parent="Playfield/Holds" instance=ExtResource("12_hold_scene")]
[node name="Hold5" parent="Playfield/Holds" instance=ExtResource("12_hold_scene")]
```

**File:** `scenes/Main.tscn` (lines 262, 266, 270, 274)  
**Time:** 2024-12-19  
**Status:** ✅ FIXED

**Note:** This was a cascading issue from Bug 11 (background texture addition). When the background texture was added as id="11", it pushed the Hold scene to id="12", but not all references were updated initially.

---

**Last Updated:** 2024-12-19

