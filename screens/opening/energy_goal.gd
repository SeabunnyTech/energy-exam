extends BaseScreen


@onready var button = $StartButton
@onready var image = $GoalImage

var beat_tween: Tween
var initial_button_position_y: float

# Frame animation
var frames: Array[Texture2D] = []
var frame_durations: Array[float] = [0.17, 0.50, 0.17, 0.13, 0.33, 0.33, 0.37, 0.33, 1.67]
var current_frame: int = 0
var frame_timer: float = 0.0


func _ready():
	button.pressed.connect(_on_button_pressed)
	initial_button_position_y = button.position.y
	ui_to_fade = [self, image, button]
	_load_frames()
	reset()


func _load_frames():
	for i in range(9):
		var path = "res://screens/opening/goal_frames/frame_%02d.png" % i
		var tex = load(path)
		if tex:
			frames.append(tex)


func _process(delta):
	if frames.is_empty() or current_frame >= frames.size() - 1:
		return
	frame_timer += delta
	if frame_timer >= frame_durations[current_frame]:
		frame_timer -= frame_durations[current_frame]
		current_frame += 1
		image.texture = frames[current_frame]


func start_beat_animation():
	if beat_tween and beat_tween.is_valid():
		return

	button.pivot_offset = button.size / 2
	beat_tween = create_tween().set_loops()

	var jump_duration = 0.1

	beat_tween.tween_property(button, "scale", Vector2(1.03, 1.03), jump_duration)\
			  .set_trans(Tween.TRANS_SINE)\
			  .set_ease(Tween.EASE_OUT)
	beat_tween.parallel()\
			  .tween_property(button, "position:y", initial_button_position_y - 5, jump_duration)\
			  .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	beat_tween.chain().tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	beat_tween.parallel().tween_property(button, "position:y", initial_button_position_y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	beat_tween.chain().tween_interval(1.2)


func stop_beat_animation():
	if not beat_tween:
		return

	beat_tween.kill()
	beat_tween = null
	button.scale = Vector2(1.0, 1.0)
	button.position.y = initial_button_position_y


func set_input_enable(enable):
	button.disabled = not enable

	if enable:
		start_beat_animation()
	else:
		stop_beat_animation()


func on_pre_enter(_param):
	current_frame = 0
	frame_timer = 0.0
	if not frames.is_empty():
		image.texture = frames[0]


func _on_button_pressed():
	leave_for_screen("intro")
