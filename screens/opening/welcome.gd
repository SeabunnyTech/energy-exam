extends BaseScreen


@onready var button = $StartButton
@onready var bg_video: VideoStreamPlayer = $BgVideo

var beat_tween: Tween
var video_fade_tween: Tween
var initial_button_position_y: float

@export var idle_music: AudioStream

const FADE_DURATION := 0.8
const VIDEO_DURATION := 12.9


func _ready():
	button.pressed.connect(_on_enter_map_button_pressed)
	initial_button_position_y = button.position.y
	ui_to_fade = [self, button]
	bg_video.finished.connect(_on_video_finished)
	reset()


func _process(_delta):
	if not bg_video.is_playing():
		return
	var pos = bg_video.stream_position
	if pos >= VIDEO_DURATION - FADE_DURATION:
		_start_fade_out()


func _start_fade_out():
	if video_fade_tween and video_fade_tween.is_valid():
		return
	video_fade_tween = create_tween()
	video_fade_tween.tween_property(bg_video, "modulate:a", 0.0, FADE_DURATION)


func _on_video_finished():
	bg_video.modulate.a = 0.0
	bg_video.play()
	if video_fade_tween and video_fade_tween.is_valid():
		video_fade_tween.kill()
	video_fade_tween = create_tween()
	video_fade_tween.tween_property(bg_video, "modulate:a", 1.0, FADE_DURATION)


func on_pre_enter(_param):
	GlobalAudioPlayer.play_music(idle_music, 1.)
	GameState.reset_all_scores()
	bg_video.modulate.a = 1.0
	bg_video.play()


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


func _on_enter_map_button_pressed():
	leave_for_screen("intro")
