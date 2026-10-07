extends BaseScreen

var map_name
var topic

var celebration_frames: Array[Texture2D] = []
var celebration_durations := [0.2, 0.2, 0.1]  # seconds per frame
var current_frame := 0
var frame_timer := 0.0


func on_pre_enter(_param):
	$GuideLabel.text = Lang.t("congrats_title")
	$GuideLabel2.text = Lang.t("congrats_guide")
	Lang.fit_font($GuideLabel, 75, 40)
	Lang.fit_font($GuideLabel2, 45, 24)


func on_enter(_param):
	pass
	#$sfx.play()


func _ready() -> void:
	ui_to_fade = [$GuideLabel, $GuideLabel2, %LeaveButton, $TextureRect, $QRCodeRect]

	for i in 3:
		celebration_frames.append(load("res://screens/ending/celebration/frame_%d.png" % i))

	%LeaveButton.pressed.connect(_on_leave_pressed)
	reset()


func _process(delta):
	if celebration_frames.is_empty():
		return
	frame_timer += delta
	if frame_timer >= celebration_durations[current_frame]:
		frame_timer = 0.0
		current_frame = (current_frame + 1) % celebration_frames.size()
		$TextureRect.texture = celebration_frames[current_frame]


func _on_leave_pressed():
	leave_for_screen('welcome')
	GlobalAudioPlayer.fade_out(1.0)
