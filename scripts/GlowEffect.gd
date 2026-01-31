extends Node2D

## v3.0: Glow Effect Component
## Adds neon glow effect to game elements (bumpers, skill shots, flippers, etc.)

@export var glow_color: Color = Color(1.0, 1.0, 0.0, 1.0)  # Yellow glow (default)
@export var glow_intensity: float = 1.5  # Intensity multiplier
@export var glow_size: float = 2.0  # Size multiplier relative to parent
@export var pulse_enabled: bool = true  # Enable pulsing animation
@export var pulse_speed: float = 2.0  # Pulse animation speed

var glow_sprite: Sprite2D = null
var base_alpha: float = 0.6
var pulse_timer: float = 0.0

func _ready():
	_create_glow_effect()

func _create_glow_effect():
	"""Create glow effect using sprite with additive blending"""
	# Create glow sprite
	glow_sprite = Sprite2D.new()
	glow_sprite.name = "GlowSprite"
	
	# Try to load glow texture, fallback to creating programmatic circle
	var glow_texture = _create_glow_texture()
	glow_sprite.texture = glow_texture
	
	# Configure glow properties
	glow_sprite.modulate = glow_color
	glow_sprite.scale = Vector2(glow_size, glow_size)
	glow_sprite.z_index = -1  # Behind parent
	glow_sprite.z_as_relative = true
	
	# Use additive blending for glow effect (Godot 4: requires CanvasItemMaterial)
	var material = CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow_sprite.material = material
	
	add_child(glow_sprite)

func _create_glow_texture() -> Texture2D:
	"""Create a glow texture programmatically (white circle with transparent edges)"""
	# Try to load existing glow texture first
	var texture_path = "res://assets/sprites/glow_circle.png"
	if ResourceLoader.exists(texture_path):
		return load(texture_path) as Texture2D
	
	# Create programmatic glow texture
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = Vector2(32, 32)
	var radius = 30.0
	
	# Draw gradient circle (bright center, transparent edges)
	for x in range(64):
		for y in range(64):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)
			if dist < radius:
				var alpha = 1.0 - (dist / radius)
				alpha = pow(alpha, 2.0)  # Smooth falloff
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	
	var texture = ImageTexture.create_from_image(image)
	return texture

func _process(delta):
	if pulse_enabled and glow_sprite:
		pulse_timer += delta * pulse_speed
		var pulse_alpha = base_alpha + 0.3 * sin(pulse_timer)
		var current_color = glow_color
		current_color.a = pulse_alpha * glow_intensity
		glow_sprite.modulate = current_color

func set_glow_color(color: Color):
	"""Update glow color"""
	glow_color = color
	if glow_sprite:
		glow_sprite.modulate = glow_color

func set_glow_intensity(intensity: float):
	"""Update glow intensity"""
	glow_intensity = clamp(intensity, 0.0, 3.0)
	if glow_sprite:
		var current_color = glow_sprite.modulate
		current_color.a = base_alpha * glow_intensity
		glow_sprite.modulate = current_color

func set_glow_size(size: float):
	"""Update glow size"""
	glow_size = clamp(size, 0.5, 5.0)
	if glow_sprite:
		glow_sprite.scale = Vector2(glow_size, glow_size)

func enable_pulse(enabled: bool):
	"""Enable/disable pulse animation"""
	pulse_enabled = enabled
