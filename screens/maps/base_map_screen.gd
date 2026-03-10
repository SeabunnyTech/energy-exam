extends BaseScreen

class_name BaseMapScreen

var buttons: Array = []
var button_topics: Dictionary = {}  # {Button: {map_name, topic}}
var idle_timer: Timer


func _ready():
	ui_to_fade = buttons

	# Create and configure the timer for the idle animation
	idle_timer = Timer.new()
	idle_timer.wait_time = 5.0
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(idle_timer)

	_setup_buttons()
	reset()


# 子類覆寫此方法來設定按鈕事件
func _setup_buttons():
	pass


func set_input_enable(enable: bool):
	for button in buttons:
		if enable and _is_topic_completed(button):
			button.disabled = true
		else:
			button.disabled = not enable

	if enable:
		idle_timer.start()
		_on_idle_timer_timeout()
	else:
		idle_timer.stop()


func _is_topic_completed(button) -> bool:
	if button not in button_topics:
		return false
	var info = button_topics[button]
	var score = GameState.get_topic_score(info['map_name'], info['topic'])
	return score['answered'] > 0


func _on_idle_timer_timeout():
	var tween = create_tween().set_loops(1).set_parallel(false)

	var jump_height = 15.0
	var jump_duration = 0.2

	for button in buttons:
		var initial_pos = button.position
		tween.chain().tween_property(button, "position", initial_pos - Vector2(0, jump_height), jump_duration)
		tween.chain().tween_property(button, "position", initial_pos, jump_duration)
		tween.chain().tween_interval(0.1)


func on_pre_enter(_param):
	reset()
	# 等待相機動畫幾乎完成後再定位按鈕（提前一點避免停頓感）
	await _wait_for_camera_almost_ready()
	_position_buttons_from_3d()


func _wait_for_camera_almost_ready():
	var current_map = _super_scene.current_map
	if not current_map or not current_map.camera:
		await get_tree().process_frame
		return

	var camera = current_map.camera
	if not camera.is_animating:
		return

	# 等待相機動畫接近完成（提前 0.3 秒開始顯示按鈕）
	var early_start_time = 0.3
	var wait_time = max(0.0, camera.default_duration - early_start_time)
	await get_tree().create_timer(wait_time).timeout


func reset():
	for btn in buttons:
		btn.reset()
		# 已答過的主題保持 disabled
		if _is_topic_completed(btn):
			btn.disabled = true


# 覆寫進場動畫，加快按鈕浮現速度
func enter_animation():
	await fade_all(1.0, 0.3, 0.08)  # 更快的淡入（原本是 0.7, 0.2）
	set_input_enable(true)
	start_beating_anim()


# 根據 3D 座標自動定位按鈕
func _position_buttons_from_3d():
	var camera = get_viewport().get_camera_3d()
	if not camera:
		push_warning("BaseMapScreen: 找不到 Camera3D")
		return

	# 從地圖取得按鈕位置
	var current_map = _super_scene.current_map
	if not current_map:
		push_warning("BaseMapScreen: 找不到 current_map")
		return

	var button_3d_positions = current_map.get_button_positions()
	if button_3d_positions.is_empty():
		return  # 地圖沒有定義 ButtonPositions，跳過自動定位

	for button in buttons:
		var button_name = button.name
		if button_name in button_3d_positions:
			var pos_3d = button_3d_positions[button_name]

			# 檢查位置是否在相機前方
			if camera.is_position_behind(pos_3d):
				button.visible = false
				continue

			button.visible = true
			var screen_pos = camera.unproject_position(pos_3d)

			# 重設 anchors 為左上角，改用絕對定位
			button.anchor_left = 0
			button.anchor_top = 0
			button.anchor_right = 0
			button.anchor_bottom = 0

			# 將按鈕尖端對準螢幕位置（尖端在按鈕底部中央向下延伸）
			# 額外往上挪動半個按鈕高度
			var pointer_height = button.pointer_size.y if button is OnMapButton else 0
			var extra_offset = button.size.y / 2
			button.position = screen_pos - Vector2(button.size.x / 2, button.size.y + pointer_height + extra_offset)


# 輔助方法：子類可用來簡化按鈕事件處理
func go_to_quiz(map_name: String, topic: String):
	# 檢查相機位置是否存在
	var camera = _super_scene.current_map.camera if _super_scene.current_map else null
	if camera and not camera.has_position(topic):
		push_warning("[go_to_quiz] 缺少相機位置 '%s'，將不會有運鏡效果" % topic)

	# 開始按鈕消失動畫（不等待完成）
	_animate_button_selection()

	# 稍微延遲後開始運鏡，讓按鈕消失和運鏡有重疊
	await get_tree().create_timer(0.15).timeout
	move_camera_to_topic(topic)

	# 延遲 pre_quiz 出現時機，讓它在運鏡幾乎到位時才浮現
	var camera_duration = camera.default_duration if camera else 1.5
	leave_for_screen("pre_quiz", {
		'map_name': map_name,
		'topic': topic,
		'time_to_next_screen_animation': camera_duration - 0.3
	})


func _animate_button_selection():
	var pressed_button: Button = null

	# 找出被按的按鈕（disabled 的那個）
	for btn in buttons:
		if btn.disabled:
			pressed_button = btn
			break

	# 其他按鈕快速淡出
	for btn in buttons:
		if btn != pressed_button:
			var fade_tween = create_tween()
			fade_tween.tween_property(btn, "modulate:a", 0.0, 0.15)

	# 被按的按鈕：跳躍後淡出
	if pressed_button:
		var tween = create_tween()
		var init_y = pressed_button.position.y
		# 跳躍動畫
		tween.tween_property(pressed_button, "position:y", init_y - 23, 0.12).set_ease(Tween.EASE_OUT)
		tween.tween_property(pressed_button, "position:y", init_y, 0.12).set_ease(Tween.EASE_IN)
		# 跳躍後淡出
		tween.tween_property(pressed_button, "modulate:a", 0.0, 0.15)
		await tween.finished
	else:
		# 如果沒有被按的按鈕，等待其他按鈕淡出完成
		await get_tree().create_timer(0.15).timeout
