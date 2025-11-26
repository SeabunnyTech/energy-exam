@tool
class_name GlowLineButton
extends PanelContainer


## The text displayed on the button.
@export var text: String = "Button Text":
	set(value):
		text = value
		if label: label.text = text

## The master corner radius for all borders and backgrounds.
@export_range(0, 100, 1) var corner_radius: int = 55:
	set(value):
		corner_radius = value
		_update_appearance()

## The width of the outermost border line.
@export_range(0, 20, 1) var outer_border_width: int = 1:
	set(value):
		outer_border_width = value
		_update_appearance()

## The color of the outermost border line.
@export var outer_border_color: Color = Color.WHITE:
	set(value):
		outer_border_color = value
		_update_appearance()

## The spacing between the outer and inner borders.
@export_range(0, 20, 1) var border_spacing: int = 10:
	set(value):
		border_spacing = value
		_update_appearance()

## The color of the space between the borders.
@export var spacing_color: Color = Color.WHITE:
	set(value):
		spacing_color = value
		_update_appearance()

## The width of the inner border line.
@export_range(0, 20, 1) var inner_border_width: int = 1:
	set(value):
		inner_border_width = value
		_update_appearance()

## The color of the inner border line.
@export var inner_border_color: Color = Color.WHITE:
	set(value):
		inner_border_color = value
		_update_appearance()

## The start color of the background gradient.
@export var gradient_start_color: Color = Color(0.355, 0.71, 0.44375):
	set(value):
		gradient_start_color = value
		_update_appearance()

## The end color of the background gradient.
@export var gradient_end_color: Color = Color(0.2555, 0.4532, 0.73):
	set(value):
		gradient_end_color = value
		_update_appearance()

## The size of the outer border's glow effect.
@export_range(0, 50, 1) var outer_outline_glow_size: int = 15:
	set(value):
		outer_outline_glow_size = value
		_update_appearance()

## The color of the outer border's glow effect.
@export var glow_color: Color = Color(1, 1, 1, 0.5):
	set(value):
		glow_color = value
		_update_appearance()


# Node references
@onready var button: Button = $MarginContainer/Button
@onready var outer_margin_container: MarginContainer = $MarginContainer
@onready var inner_border_container: PanelContainer = $MarginContainer/PanelContainer
@onready var background_panel: Panel = $MarginContainer/PanelContainer/Panel
@onready var gradient_texture_rect: TextureRect = $MarginContainer/PanelContainer/Panel/TextureRect
@onready var label: Label = $MarginContainer/PanelContainer/MarginContainer/Label


func _ready() -> void:
	_update_appearance()
	# To make scaling animation originate from the center
	pivot_offset = size / 2.0
	
	# Connect signals for feedback
	if not button.is_connected("pressed", Callable(self, "_on_pressed")):
		button.pressed.connect(_on_pressed)
	if not button.is_connected("button_down", Callable(self, "_on_button_down")):
		button.button_down.connect(_on_button_down)
	if not button.is_connected("button_up", Callable(self, "_on_button_up")):
		button.button_up.connect(_on_button_up)
	
	_update_gradient_offsets(0.0)


func _on_pressed() -> void:
	# This signal fires on a complete, valid click.
	# The main action of the button goes here.
	$SfxPlayer.play()


func _on_button_down() -> void:
	# This is for immediate visual feedback when the button is pressed down.
	# 1. Make gradient vibrant (increase saturation)
	var saturation_boost_factor = 1.3 # Adjust this value to control vibrancy

	var vibrant_start_color = gradient_start_color
	vibrant_start_color.s = min(vibrant_start_color.s * saturation_boost_factor, 1.0)

	var vibrant_end_color = gradient_end_color
	vibrant_end_color.s = min(vibrant_end_color.s * saturation_boost_factor, 1.0)

	_update_gradient(vibrant_start_color, vibrant_end_color)

	# 2. Create parallel animation
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	# 3. Animate gradient squeeze effect
	tween.tween_method(_update_gradient_offsets, 0.0, 0.25, 0.1)

	# 4. Scale down animation
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)


func _on_button_up() -> void:
	# This is for reverting the visual feedback when the button is released.
	# 1. Revert gradient to normal
	_update_gradient(gradient_start_color, gradient_end_color)

	# 2. Create parallel animation
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	# 3. Animate gradient squeeze back
	tween.tween_method(_update_gradient_offsets, 0.25, 0.0, 0.1)

	# 4. Scale back animation
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)


func _update_appearance() -> void:
	if not is_inside_tree():
		return
		
	pivot_offset = size / 2.0

	# --- Update Outer Border and Spacing ---
	var outer_style: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	outer_style.border_color = outer_border_color
	outer_style.border_width_left = outer_border_width
	outer_style.border_width_top = outer_border_width
	outer_style.border_width_right = outer_border_width
	outer_style.border_width_bottom = outer_border_width
	outer_style.bg_color = spacing_color
	outer_style.set_corner_radius_all(corner_radius)
	
	# --- Add Glow Effect ---
	if glow_color:
		outer_style.shadow_size = outer_outline_glow_size
		outer_style.shadow_color = glow_color
		outer_style.shadow_offset = Vector2.ZERO
	
	add_theme_stylebox_override("panel", outer_style)
	
	outer_margin_container.add_theme_constant_override("margin_left", border_spacing)
	outer_margin_container.add_theme_constant_override("margin_top", border_spacing)
	outer_margin_container.add_theme_constant_override("margin_right", border_spacing)
	outer_margin_container.add_theme_constant_override("margin_bottom", border_spacing)

	# --- Update Inner Border ---
	var inner_radius = max(0, corner_radius - outer_border_width - border_spacing)
	var inner_style: StyleBoxFlat = inner_border_container.get_theme_stylebox("panel").duplicate()
	inner_style.border_color = inner_border_color
	inner_style.border_width_left = inner_border_width
	inner_style.border_width_top = inner_border_width
	inner_style.border_width_right = inner_border_width
	inner_style.border_width_bottom = inner_border_width
	inner_style.set_corner_radius_all(inner_radius)
	inner_border_container.add_theme_stylebox_override("panel", inner_style)

	# --- Update Background Panel ---
	var bg_radius = max(0, inner_radius - inner_border_width)
	var bg_style: StyleBoxFlat = background_panel.get_theme_stylebox("panel").duplicate()
	bg_style.set_corner_radius_all(bg_radius)
	background_panel.add_theme_stylebox_override("panel", bg_style)
	
	# --- Update Gradient ---
	_update_gradient(gradient_start_color, gradient_end_color)

	# --- Update Text ---
	if label:
		label.text = text


func _update_gradient(start_color: Color, end_color: Color) -> void:
	if not gradient_texture_rect.texture:
		gradient_texture_rect.texture = GradientTexture1D.new()
	if not gradient_texture_rect.texture.gradient:
		gradient_texture_rect.texture.gradient = Gradient.new()
	
	var gradient: Gradient = gradient_texture_rect.texture.gradient
	gradient.set_color(0, start_color)
	gradient.set_color(1, end_color)


func _update_gradient_offsets(squeeze_amount: float) -> void:
	if gradient_texture_rect.texture and gradient_texture_rect.texture.gradient:
		var gradient: Gradient = gradient_texture_rect.texture.gradient
		gradient.offsets = PackedFloat32Array([squeeze_amount, 1.0 - squeeze_amount])
