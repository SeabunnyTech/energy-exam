extends BaseScreen


@onready var button = $Control/StartButton
@onready var title = $Control/TitleLabel
@onready var guide = $Control/GuideLabel
@onready var photo = $Control/PhotoRect

var beat_tween: Tween
var initial_button_position_y: float

var map_name:String
var topic:String


func on_pre_enter(param):
	map_name = param['map_name']
	topic = param['topic']
	var title_and_guide = GameState.load_topic_title_and_guide(map_name, topic)
	title.text = title_and_guide['title']
	guide.text = title_and_guide['guide']
	button.text = Lang.t("start")
	Lang.fit_font(title, 96, 48)
	Lang.fit_font(guide, 42, 24)

	# 載入主題照片（支援 .jpg 和 .png）
	var photo_loaded := false
	for ext in ["jpg", "png"]:
		var photo_path = "res://screens/quiz/photo/%s.%s" % [topic, ext]
		if ResourceLoader.exists(photo_path):
			photo.texture = load(photo_path)
			photo_loaded = true
			break
	if not photo_loaded:
		push_warning("[PreQuizScreen] 找不到照片: res://screens/quiz/photo/%s.*" % topic)
		photo.texture = null


func _ready():
	button.pressed.connect(_on_enter_map_button_pressed)
	%BackButton.pressed.connect(_on_back_pressed)
	initial_button_position_y = button.position.y # Initialize here
	ui_to_fade = [self, title, photo, guide, button, %BackButton]
	reset()


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
	%BackButton.disabled = not enable

	if enable:
		start_beat_animation()
	else:
		stop_beat_animation()


func _on_enter_map_button_pressed():
	var sfx:AudioStreamPlayer = $AudioStreamPlayer
	sfx.play()
	leave_for_screen("quiz", {'map_name':map_name, 'topic':topic, 'index':0})


func _on_back_pressed():
	# 相機回到 overview 位置
	move_camera_to_topic('overview')
	# 返回到對應的地圖畫面
	leave_for_screen(map_name)
