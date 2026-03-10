## RecordTool - 螢幕錄影自動化工具
## 以正常玩家速度自動操作遊戲流程，搭配 Godot --write-movie 錄影
## 用法：
##   godot --write-movie recording.avi -- --record-demo
extends Node


var _is_active: bool = false
var _super_scene: Node = null


func _ready() -> void:
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg == "--record-demo":
			_is_active = true
			break

	if not _is_active:
		return

	print("[RecordTool] 錄影模式啟動")
	await get_tree().create_timer(1.0).timeout
	_start_recording()


func _start_recording() -> void:
	_super_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)

	if not _super_scene or not _super_scene.has_method("goto_screen"):
		push_error("[RecordTool] 找不到 SuperScene，結束")
		get_tree().quit(1)
		return

	# === 開場 ===
	await _wait_for_screen("welcome")
	await _pause(2.0)
	_press_button("StartButton")

	# Intro — 翻過所有頁
	await _wait_for_screen("intro")
	await _skip_intro()

	# 選擇地圖
	await _wait_for_screen("select_map")
	await _pause(2.0)
	_select_map_card("coast")

	# === 第一個主題：wind ===
	await _wait_for_screen("coast")
	await _pause(2.5)
	_press_button("WindPowerButton")

	await _play_quiz_flow()

	# policy 畫面 → 按「還想了解其他設施」回地圖
	await _wait_for_screen("policy")
	await _pause(4.0)
	_press_button("BackToMapButton")

	# === 第二個主題：solar_ground ===
	await _wait_for_screen("map_changing")
	await _wait_for_screen("coast")
	await _pause(2.5)
	_press_button("GroundSolarButton")

	await _play_quiz_flow()

	# policy 畫面 → 按「我瞭解了！」去獎品頁
	await _wait_for_screen("policy")
	await _pause(4.0)
	_press_button("LeaveButton")

	# === 結束：congrats ===
	await _wait_for_screen("congrats")
	await _pause(3.0)

	print("[RecordTool] 錄影流程完成")
	get_tree().quit()


## 執行一輪完整的 quiz 流程（pre_quiz → quiz → result）
func _play_quiz_flow() -> void:
	await _wait_for_screen("pre_quiz")
	await _pause(2.0)
	_press_button("StartButton")

	# 答 3 題
	await _wait_for_screen("quiz")
	var screen = _super_scene._current_screen

	for i in range(3):
		if _super_scene._current_screen != screen:
			break
		await _pause(2.0)

		# 找正確答案按鈕並按下
		var container = screen.answer_container
		if container:
			var correct_btn = _find_correct_button(container)
			if correct_btn:
				correct_btn.pressed.emit()

		# 等待答題動畫 + 下一題過場
		await _pause(2.5)

	# 等進入 result 畫面
	await _wait_for_screen("result")
	await _pause(2.5)
	_press_button("MorePolicyButton")


# ─── 輔助函式 ───

func _pause(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _wait_for_screen(screen_name: String) -> void:
	if not _super_scene.screen_instances.has(screen_name):
		push_warning("[RecordTool] 未知畫面：%s" % screen_name)
		return

	var expected = _super_scene.screen_instances[screen_name]
	var timeout := 15.0
	var elapsed := 0.0

	while _super_scene._current_screen != expected and elapsed < timeout:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1

	if elapsed >= timeout:
		push_warning("[RecordTool] 等待 %s 超時" % screen_name)
		return

	# 等動畫完成
	await _pause(1.0)


func _press_button(button_name: String) -> void:
	var screen = _super_scene._current_screen
	var button = screen.find_child(button_name, true, false)
	if button:
		print("[RecordTool] 按下按鈕：%s" % button_name)
		button.pressed.emit()
	else:
		push_warning("[RecordTool] 找不到按鈕：%s" % button_name)


func _select_map_card(map_name: String) -> void:
	var screen = _super_scene._current_screen
	var container = screen.find_child("HBoxContainer", true, false)
	if not container:
		return
	for card in container.get_children():
		if card.get("map_name") == map_name:
			print("[RecordTool] 選擇地圖：%s" % map_name)
			card.button_pressed.emit()
			return


func _skip_intro() -> void:
	var screen = _super_scene._current_screen
	var button = screen.find_child("StartButton", true, false)
	if not button:
		return

	while _super_scene._current_screen == screen:
		await _wait_for_button_enabled(button)
		if _super_scene._current_screen != screen:
			break
		await _pause(2.0)
		button.pressed.emit()
		await _pause(0.5)


func _wait_for_button_enabled(button: BaseButton, timeout: float = 5.0) -> void:
	var elapsed := 0.0
	while button.disabled and elapsed < timeout:
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05


func _find_correct_button(container) -> QuizButton:
	for btn in container.get_children():
		if btn is QuizButton and btn.is_correct_answer and not btn.disabled:
			return btn
	return null
