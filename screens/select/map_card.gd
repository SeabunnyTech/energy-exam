@tool
extends MarginContainer

signal button_pressed

@export var title: String = "Default Title":
	set(value):
		title = value
		if title_label:
			title_label.text = value

@export_multiline var guide: String = "Default guide text.":
	set(value):
		guide = value
		if guide_label:
			guide_label.text = value

@export var map_name: String = ""

@export var map_texture: Texture2D:
	set(value):
		map_texture = value
		if map_image:
			map_image.texture = value

var title_label: Label
var guide_label: Label
var map_image: TextureRect
var button: Button


func _ready() -> void:
	title_label = $Outline/MarginContainer/Panel/TitleLabel
	guide_label = $Outline/MarginContainer/Panel/GuideLabel
	map_image = $Outline/MarginContainer/Panel/MapImage
	button = $Outline/MarginContainer/Panel/Button

	title_label.text = title
	guide_label.text = guide
	if map_texture:
		map_image.texture = map_texture

	if not Engine.is_editor_hint():
		button.pressed.connect(_button_pressed)


func _button_pressed():
	$AudioStreamPlayer.play()
	button_pressed.emit()


func play_jump_animation(delay):
	var tween = create_tween()

	var jump_height = 10.0
	var jump_duration = 0.3

	var card_initial_position = position

	# Phase 1: Card jumps up and down
	tween.tween_property(self, "position", card_initial_position - Vector2(0, jump_height),\
						jump_duration)\
						.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)\
						.set_delay(delay)

	tween.tween_property(self, "position", card_initial_position, jump_duration)\
						.set_trans(Tween.TRANS_SINE)\
						.set_ease(Tween.EASE_IN)
