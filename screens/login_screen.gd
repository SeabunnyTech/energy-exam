extends BaseScreen


@onready var button = $Control/EnterMapButton
@onready var title = $Control/TitleLabel
@onready var guide = $Control/GuideLabel

var beat_tween: Tween
var initial_button_position_y: float

@export var idle_music: AudioStream



func _ready():
	button.pressed.connect(_on_enter_map_button_pressed)
	initial_button_position_y = button.position.y # Initialize here
	ui_to_fade = [self, title, guide, button]
	reset()


func on_pre_enter(_param):
	GlobalAudioPlayer.play_music(idle_music, 1.)


func start_beat_animation():
	if beat_tween and beat_tween.is_valid():
		return # Animation is already running

	button.pivot_offset = button.size / 2
	beat_tween = create_tween().set_loops()

	var jump_duration = 0.1

	# Phase 1: Scale up and Move up (parallel)
	beat_tween.tween_property(button, "scale", Vector2(1.03, 1.03), jump_duration)\
			  .set_trans(Tween.TRANS_SINE)\
			  .set_ease(Tween.EASE_OUT)
	beat_tween.parallel()\
			  .tween_property(button, "position:y", initial_button_position_y - 5, jump_duration)\
			  .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Phase 2: Scale down and Move down (parallel, chained after Phase 1)
	beat_tween.chain().tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	beat_tween.parallel().tween_property(button, "position:y", initial_button_position_y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Phase 3: Interval (chained after Phase 2)
	beat_tween.chain().tween_interval(1.2)


func stop_beat_animation():
	if not beat_tween:
		return
	
	beat_tween.kill()
	beat_tween = null
	button.scale = Vector2(1.0, 1.0)
	button.position.y = initial_button_position_y # Reset position


func set_input_enable(enable):
	button.disabled = not enable

	if enable:
		start_beat_animation()
	else:
		stop_beat_animation()


func _on_enter_map_button_pressed():
	var sfx:AudioStreamPlayer = $AudioStreamPlayer
	sfx.play()
	#await sfx.finished
	leave_for_screen("select_map")
