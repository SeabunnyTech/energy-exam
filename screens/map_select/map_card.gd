@tool
extends MarginContainer

signal button_pressed

@export var title: String = "Default Title"
@export var guide: String = "Default guide text."
@export var map_name: String = ""
@export var map_texture: Texture2D

@onready var title_label: Label = $Outline/MarginContainer/Panel/TitleLabel
@onready var guide_label: Label = $Outline/MarginContainer/Panel/GuideLabel
@onready var map_image: TextureRect = $Outline/MarginContainer/Panel/MapImage

@onready var button: Button = $Outline/MarginContainer/Panel/Button


func _ready() -> void:
	title_label.text = title
	guide_label.text = guide
	button.pressed.connect(_button_pressed)
	if map_texture:
		map_image.texture = map_texture


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
