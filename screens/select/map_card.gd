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


# 英文字數多，放寬標題與說明的範圍（中文維持原本版面）；順序為 [左, 上, 右, 下]
const TITLE_ANCHORS_ZH := [0.22358, 0.10912, 0.77642, 0.19088]
const TITLE_ANCHORS_EN := [0.06, 0.10912, 0.94, 0.19088]
const GUIDE_ANCHORS_ZH := [0.069123, 0.56827, 0.950066, 0.75273]
const GUIDE_ANCHORS_EN := [0.04, 0.55, 0.96, 0.795]

func apply_language() -> void:
	title = Lang.t("map_%s_title" % map_name)
	guide = Lang.t("map_%s_guide" % map_name)
	button.text = Lang.t("select_map_button")

	_set_anchors(title_label, TITLE_ANCHORS_EN if Lang.is_en() else TITLE_ANCHORS_ZH)
	_set_anchors(guide_label, GUIDE_ANCHORS_EN if Lang.is_en() else GUIDE_ANCHORS_ZH)


func _set_anchors(control: Control, anchors: Array) -> void:
	for side in 4:
		control.set_anchor(side, anchors[side], true, false)


## 依卡片大小調整字級，需在排版完成後呼叫
func fit_fonts() -> void:
	Lang.fit_font(title_label, 60, 30)
	Lang.fit_font(guide_label, 30, 16)


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
