extends Node
## v4.0 CRT Post-Processing Effects
## Adds retro CRT monitor effects: scanlines, glow, chromatic aberration

@export var enabled: bool = true
@export var scanline_intensity: float = 0.3
@export var glow_strength: float = 0.5
@export var chromatic_aberration: float = 0.002
@export var curvature_amount: float = 0.05
@export var vignette_intensity: float = 0.3
@export var noise_intensity: float = 0.02

var _material: ShaderMaterial = null

const SCANLINE_SHADER = """
shader_type canvas_item;

uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float glow_strength : hint_range(0.0, 2.0) = 0.5;
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.002;
uniform float curvature_amount : hint_range(0.0, 0.2) = 0.05;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float noise_intensity : hint_range(0.0, 0.1) = 0.02;
uniform float time_scale : hint_range(0.0, 10.0) = 1.0;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

vec2 curve_coords(vec2 uv) {
    vec2 centered = uv - 0.5;
    vec2 offset = centered * curvature_amount * dot(centered, centered);
    return uv + offset;
}

void fragment() {
    vec2 curved_uv = curve_coords(SCREEN_UV);
    
    // Curvature effect (discard edges)
    if (curved_uv.x < 0.0 || curved_uv.x > 1.0 || curved_uv.y < 0.0 || curved_uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    
    // Chromatic aberration
    float r = texture(screen_texture, curved_uv + vec2(chromatic_aberration, 0.0)).r;
    float g = texture(screen_texture, curved_uv).g;
    float b = texture(screen_texture, curved_uv - vec2(chromatic_aberration, 0.0)).b;
    
    vec3 color = vec3(r, g, b);
    
    // Glow boost
    color += color * glow_strength * 0.1;
    
    // Scanlines
    float scanline = sin(SCREEN_UV.y * 800.0) * 0.5 + 0.5;
    color *= 1.0 - scanline * scanline_intensity;
    
    // Vignette
    vec2 vignette_uv = SCREEN_UV * (1.0 - SCREEN_UV.yx);
    float vignette = vignette_uv.x * vignette_uv.y * 15.0;
    vignette = pow(vignette, vignette_intensity);
    color *= vignette;
    
    // Subtle noise
    float noise = fract(sin(dot(SCREEN_UV * time_scale + TIME, vec2(12.9898, 78.233))) * 43758.5453);
    color += (noise - 0.5) * noise_intensity;
    
    // Color boost for retro feel
    color = pow(color, vec3(0.9, 0.95, 1.0));
    
    COLOR = vec4(color, 1.0);
}
"""

func _ready() -> void:
	add_to_group("post_processing")
	_setup_effects()

func _setup_effects() -> void:
	# Create a ColorRect that covers the entire screen
	var color_rect = ColorRect.new()
	color_rect.name = "CRTEffect"
	color_rect.anchor_right = 1.0
	color_rect.anchor_bottom = 1.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create shader material
	var shader = Shader.new()
	shader.code = SCANLINE_SHADER
	_material = ShaderMaterial.new()
	_material.shader = shader
	
	color_rect.material = _material
	add_child(color_rect)

func _process(delta: float) -> void:
	if _material:
		_material.set_shader_parameter("time_scale", Time.get_ticks_msec() / 1000.0)

func set_enabled(enabled_state: bool) -> void:
	enabled = enabled_state
	var effect_rect = get_node_or_null("CRTEffect") as CanvasItem
	if effect_rect:
		effect_rect.visible = enabled

func set_scanline_intensity(value: float) -> void:
	scanline_intensity = clamp(value, 0.0, 1.0)
	if _material:
		_material.set_shader_parameter("scanline_intensity", scanline_intensity)

func set_glow_strength(value: float) -> void:
	glow_strength = clamp(value, 0.0, 2.0)
	if _material:
		_material.set_shader_parameter("glow_strength", glow_strength)

func set_chromatic_aberration(value: float) -> void:
	chromatic_aberration = clamp(value, 0.0, 0.01)
	if _material:
		_material.set_shader_parameter("chromatic_aberration", chromatic_aberration)

func set_curvature(value: float) -> void:
	curvature_amount = clamp(value, 0.0, 0.2)
	if _material:
		_material.set_shader_parameter("curvature_amount", curvature_amount)

func set_vignette(value: float) -> void:
	vignette_intensity = clamp(value, 0.0, 1.0)
	if _material:
		_material.set_shader_parameter("vignette_intensity", vignette_intensity)

func set_noise(value: float) -> void:
	noise_intensity = clamp(value, 0.0, 0.1)
	if _material:
		_material.set_shader_parameter("noise_intensity", noise_intensity)

func toggle() -> void:
	set_enabled(not enabled)

func flash(intensity: float = 0.5) -> void:
	# Screen flash effect
	if _material:
		var original_glow = glow_strength
		set_glow_strength(glow_strength + intensity)
		await get_tree().create_timer(0.1).timeout
		set_glow_strength(original_glow)

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("post_processing")
	return null
