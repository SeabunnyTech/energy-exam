## TestTool - 自動化測試工具
## 透過模擬按鈕點擊驗證 Quiz 系統行為
## 用法：
##   godot --run-tests         → 執行所有測試
##   godot --run-tests quick   → 只跑快速測試（不含完整流程）
##   godot --run-tests 8       → 只跑指定編號的測試（可用逗號：8,10）
extends Node


var _is_active: bool = false
var _super_scene: Node = null
var _pass_count: int = 0
var _fail_count: int = 0
var _current_test: String = ""
var _selected: Array[int] = []  # 要跑的測試編號


func _ready() -> void:
	var args = OS.get_cmdline_args()
	var test_arg := ""

	for i in range(args.size()):
		if args[i] == "--run-tests":
			test_arg = "all"
			if i + 1 < args.size() and not args[i + 1].begins_with("--"):
				test_arg = args[i + 1]
			break

	if test_arg.is_empty():
		return

	_is_active = true
	_selected = _parse_selection(test_arg)
	if _selected.is_empty():
		push_error("[TestTool] 無效的測試參數：%s" % test_arg)
		get_tree().quit(1)
		return
	print("[TestTool] 測試模式啟動，參數：%s" % test_arg)

	await get_tree().create_timer(1.0).timeout
	_run_all_tests()


# ─── 測試執行 ───

func _run_all_tests() -> void:
	_super_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	if not _super_scene or not _super_scene.has_method("goto_screen"):
		push_error("[TestTool] 找不到 SuperScene，結束")
		get_tree().quit(1)
		return

	print("[TestTool] ====== 開始測試 ======")

	var tests := _all_tests()
	for n in _selected:
		await tests[n].call()

	print("[TestTool] ====== 測試結束 ======")
	print("[TestTool] PASS: %d, FAIL: %d" % [_pass_count, _fail_count])

	var exit_code = 0 if _fail_count == 0 else 1
	get_tree().quit(exit_code)


## 測試編號 → 測試函式；all 的執行順序與原本相同（快速測試在前）
func _all_tests() -> Dictionary:
	return {
		1: _test_1_basic_answer,
		2: _test_2_wrong_then_correct,
		3: _test_3_double_tap_wrong,
		4: _test_4_correct_then_tap_wrong,
		5: _test_5_double_tap_two_wrong,
		6: _test_6_disable_after_correct,
		10: _test_10_language_switch,
		11: _test_11_narration,
		7: _test_7_cumulative_score,
		8: _test_8_map_button_disable,
		9: _test_9_reset_scores,
	}


const QUICK_TESTS: Array[int] = [1, 2, 3, 4, 5, 6, 10, 11]


## quick / all / 逗號分隔的編號；無效時回傳空陣列
func _parse_selection(arg: String) -> Array[int]:
	var tests := _all_tests()
	var result: Array[int] = []
	if arg == "all":
		result.assign(tests.keys())
	elif arg == "quick":
		result = QUICK_TESTS.duplicate()
	else:
		for part in arg.split(","):
			var n := part.strip_edges().to_int()
			if not tests.has(n):
				return []
			result.append(n)
	return result


# ─── 測試案例 ───

## 1. 基本答題流程
func _test_1_basic_answer() -> void:
	_current_test = "1. 基本答題流程"
	print("\n[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()

	await _navigate_to_quiz("coast", "wind")
	var screen = _super_scene._current_screen

	var correct_btn = _find_correct_button(screen.answer_container)
	assert_true(correct_btn != null, "找到正確按鈕")

	var score_before = GameState.total_score
	correct_btn.pressed.emit()
	await get_tree().create_timer(0.5).timeout

	var score = GameState.get_topic_score("coast", "wind")
	assert_eq(score["answered"], 1, "answered=1")
	assert_eq(score["correct"], 1, "correct=1")
	assert_eq(GameState.total_score, score_before + 1, "total_score 增加")

	await _navigate_back_to_welcome()


## 2. 答錯再答對
func _test_2_wrong_then_correct() -> void:
	_current_test = "2. 答錯再答對"
	print("\n[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()

	await _navigate_to_quiz("coast", "wind")
	var screen = _super_scene._current_screen

	var wrong_btn = _find_wrong_button(screen.answer_container)
	assert_true(wrong_btn != null, "找到錯誤按鈕")
	wrong_btn.pressed.emit()
	await get_tree().create_timer(0.5).timeout

	assert_true(wrong_btn.disabled, "錯誤按鈕被 disabled")

	var correct_btn = _find_correct_button(screen.answer_container)
	correct_btn.pressed.emit()
	await get_tree().create_timer(0.5).timeout

	var score = GameState.get_topic_score("coast", "wind")
	assert_eq(score["correct"], 0, "correct=0（got_wrong 生效）")
	assert_eq(GameState.total_score, 0, "total_score 不增加")

	await _navigate_back_to_welcome()


## 3. 快速連按同一個錯誤按鈕
func _test_3_double_tap_wrong() -> void:
	_current_test = "3. 快速連按同一錯誤按鈕"
	print("\n[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()

	await _navigate_to_quiz("coast", "wind")
	var screen = _super_scene._current_screen

	var wrong_btn = _find_wrong_button(screen.answer_container)
	assert_true(wrong_btn != null, "找到錯誤按鈕")

	# 快速連發兩次（不加 await）
	wrong_btn.pressed.emit()
	wrong_btn.pressed.emit()
	await get_tree().create_timer(0.5).timeout

	assert_true(screen.got_wrong, "got_wrong=true")
	assert_eq(GameState.total_score, 0, "score 正常（不崩潰）")

	await _navigate_back_to_welcome()


## 4. 快速連按：先按對再試按錯
func _test_4_correct_then_tap_wrong() -> void:
	_current_test = "4. 先按對再試按錯"
	print("\n[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()

	await _navigate_to_quiz("coast", "wind")
	var screen = _super_scene._current_screen

	var correct_btn = _find_correct_button(screen.answer_container)
	var wrong_btn = _find_wrong_button(screen.answer_container)

	# 按正確答案後立即按錯誤按鈕（不加 await）
	correct_btn.pressed.emit()
	wrong_btn.pressed.emit()
	await get_tree().create_timer(0.5).timeout

	assert_eq(GameState.total_score, 1, "score 只計一次")
	var score = GameState.get_topic_score("coast", "wind")
	assert_eq(score["answered"], 1, "answered 只計一次")

	await _navigate_back_to_welcome()


## 5. 快速連按兩個不同的錯誤按鈕
func _test_5_double_tap_two_wrong() -> void:
	_current_test = "5. 快速連按兩個不同錯誤按鈕"
	print("\n[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()

	await _navigate_to_quiz("coast", "wind")
	var screen = _super_scene._current_screen

	var wrong_btns = _find_wrong_buttons(screen.answer_container, 2)
	assert_true(wrong_btns.size() >= 2, "找到至少 2 個錯誤按鈕")

	# 同時連發兩個錯誤按鈕（不加 await）
	wrong_btns[0].pressed.emit()
	wrong_btns[1].pressed.emit()
	await get_tree().create_timer(0.5).timeout

	assert_true(wrong_btns[0].disabled, "第一個錯誤按鈕被 disabled")
	assert_true(wrong_btns[1].disabled, "第二個錯誤按鈕被 disabled")
	assert_true(screen.got_wrong, "got_wrong=true")
	assert_eq(GameState.total_score, 0, "不崩潰，score 正常")

	await _navigate_back_to_welcome()


## 6. 答對後 disable 驗證
func _test_6_disable_after_correct() -> void:
	_current_test = "6. 答對後所有按鈕 disabled"
	print("\n[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()

	await _navigate_to_quiz("coast", "wind")
	var screen = _super_scene._current_screen

	var correct_btn = _find_correct_button(screen.answer_container)
	# 記住當前的 answer_container 引用（emit 後可能切到下一題）
	var container = screen.answer_container
	correct_btn.pressed.emit()
	# 立即檢查（同步，load_next_question 的 await 尚未 yield）
	var all_disabled = true
	for btn in container.get_children():
		if not btn.disabled:
			all_disabled = false
	assert_true(all_disabled, "所有按鈕都被 disabled")
	await get_tree().create_timer(0.5).timeout

	await _navigate_back_to_welcome()


## 7. 累計分數跨題保留
func _test_7_cumulative_score() -> void:
	_current_test = "7. 累計分數跨題保留"
	print("\n[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()

	await _navigate_to_quiz("coast", "wind")

	# 答完 3 題（全對）
	for i in range(3):
		var screen = _super_scene._current_screen
		if screen == null or _super_scene.screen_instances.get("quiz") != screen:
			break
		var correct_btn = _find_correct_button(screen.answer_container)
		if correct_btn:
			correct_btn.pressed.emit()
			await get_tree().create_timer(1.5).timeout

	assert_eq(GameState.total_score, 3, "total_score=3")

	# 等待進入 result 畫面
	await _wait_for_screen("result")
	var result_screen = _super_scene._current_screen
	var score_label = result_screen.find_child("score", true, false)
	if score_label:
		assert_true(score_label.text.contains("3"), "result 畫面顯示正確分數")

	await _navigate_back_to_welcome_from_result()


## 8. 地圖按鈕 disable
func _test_8_map_button_disable() -> void:
	_current_test = "8. 地圖按鈕 disable"
	print("\n[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()

	# 完成 coast/wind 的 quiz flow
	await _navigate_to_quiz("coast", "wind")
	for i in range(3):
		var screen = _super_scene._current_screen
		if screen == null or _super_scene.screen_instances.get("quiz") != screen:
			break
		var correct_btn = _find_correct_button(screen.answer_container)
		if correct_btn:
			correct_btn.pressed.emit()
			await get_tree().create_timer(1.5).timeout

	# 從 policy 的「還想了解其他設施」回到同一張地圖（不經過 welcome，分數保留）
	# 注意：回 welcome 會 reset_all_scores，按鈕本來就會全部重新啟用
	await _wait_for_screen("result")
	_press_button("MorePolicyButton")
	await _wait_for_screen("policy")
	_press_button("BackToMapButton")
	await _wait_for_screen("map_changing")
	await _wait_for_screen("coast")
	# 等待 enter_animation 完成（含相機動畫 + 按鈕 fade in + set_input_enable）
	await get_tree().create_timer(3.0).timeout

	# 驗證 WindPowerButton disabled，其他未答過的 enabled
	var coast_screen = _super_scene._current_screen
	var wind_btn = coast_screen.find_child("WindPowerButton", true, false)
	assert_true(wind_btn != null and wind_btn.disabled, "WindPowerButton disabled")

	var ground_solar = coast_screen.find_child("GroundSolarButton", true, false)
	assert_true(ground_solar != null and not ground_solar.disabled, "GroundSolarButton enabled")

	await _navigate_back_to_welcome()


## 9. reset_all_scores 歸零
func _test_9_reset_scores() -> void:
	_current_test = "9. reset_all_scores 歸零"
	print("\n[TestTool] --- %s ---" % _current_test)

	# 先設一些分數
	GameState.push_score("coast", "wind", true)
	GameState.push_score("coast", "wind", false)
	assert_true(GameState.total_score > 0, "確認有分數")

	GameState.reset_all_scores()
	assert_eq(GameState.total_score, 0, "total_score=0")

	var score = GameState.get_topic_score("coast", "wind")
	assert_eq(score["answered"], 0, "answered=0")
	assert_eq(score["correct"], 0, "correct=0")


## 10. 語系切換：英文玩一輪後回首頁仍是英文；切回中文後文字與版面恢復原狀
func _test_10_language_switch() -> void:
	_current_test = "10. 語系切換"
	print("\n[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()

	await _wait_for_screen("welcome")
	_press_button("LangButton")
	assert_true(Lang.is_en(), "按語系按鈕切到英文")
	var start_btn = _super_scene._current_screen.find_child("StartButton", true, false)
	assert_eq(start_btn.text, "Start", "首頁按鈕為英文")

	await _navigate_to_quiz("coast", "wind")
	var quiz = _super_scene._current_screen
	assert_eq(quiz.q_content.text, "How does wind power convert natural energy into electricity?", "題目為英文")
	assert_eq(quiz.four_ans.get_node("Button1").text, "1.Wind drives the turbine blades", "選項為英文")

	# 回首頁後語系沿用英文
	await _navigate_back_to_welcome()
	assert_eq(Lang.current, Lang.EN, "回首頁仍是英文")
	start_btn = _super_scene._current_screen.find_child("StartButton", true, false)
	assert_eq(start_btn.text, "Start", "回首頁後按鈕仍是英文")

	# 切回中文，檢查文字與版面恢復
	_press_button("LangButton")
	assert_eq(Lang.current, Lang.ZH, "按語系按鈕切回中文")
	await _navigate_to_quiz("coast", "wind")
	quiz = _super_scene._current_screen
	assert_eq(quiz.q_content.text, "風力發電如何把自然能源轉換成電力？", "題目恢復中文")
	assert_eq(quiz.q_content.get_theme_font_size("font_size"), 80, "題目字級恢復")
	assert_eq(quiz.four_ans.get_node("Button1").get_theme_font_size("font_size"), 44, "選項字級恢復")

	var card = _super_scene.screen_instances["select_map"].find_child("MapCard", true, false)
	assert_eq(card.title_label.text, "濱海城市", "地圖卡片標題恢復中文")
	assert_true(is_equal_approx(card.title_label.anchor_left, 0.22358), "地圖卡片標題寬度恢復")
	assert_eq(card.guide_label.label_settings.font_size, 30, "地圖卡片說明字級恢復")

	var wind_btn = _super_scene.screen_instances["coast"].find_child("WindPowerButton", true, false)
	assert_eq(wind_btn.text, "離岸風電", "地圖按鈕恢復中文")
	assert_eq(wind_btn.get_theme_font_size("font_size"), 45, "地圖按鈕字級恢復")

	await _navigate_back_to_welcome()


## 11. 語音口白：英文模式播完才開放點選、背景音樂調小；中文模式不播
func _test_11_narration() -> void:
	_current_test = "11. 語音口白"
	print("
[TestTool] --- %s ---" % _current_test)
	GameState.reset_all_scores()
	var original_lang := Lang.current

	# 每個會出現的能源都要有語音，且都在 10 秒內
	var missing := []
	for map_name in GameState.reset_scores:
		for topic in GameState.reset_scores[map_name]:
			if not Narration.EN_CLIPS.has(topic):
				missing.append(topic)
	assert_eq(missing, [], "所有能源都有語音")
	var too_long := []
	for key in Narration.EN_CLIPS:
		if Narration.EN_CLIPS[key].get_length() > 10.0:
			too_long.append(key)
	assert_eq(too_long, [], "所有語音都在 10 秒內")

	# 英文：遊戲說明頁
	await _wait_for_screen("welcome")
	Lang.set_language(Lang.EN)
	_press_button("StartButton")
	await _wait_for_screen("intro")
	await get_tree().create_timer(2.0).timeout  # 淡入已結束，沒有鎖的話按鈕這時已開放
	var button = _super_scene._current_screen.find_child("StartButton", true, false)
	assert_eq(Narration.stream, Narration.EN_CLIPS["intro"], "遊戲說明頁播開場口白")
	assert_true(Narration.playing, "語音播放中")
	assert_true(button.disabled, "語音播放中不能按")
	assert_true(button.self_modulate.a < 1.0, "語音播放中按鈕變淡")

	# 背景音樂要真的變小，且語音真的有輸出到 Master
	var music_idx := AudioServer.get_bus_index(GlobalAudioPlayer.MUSIC_BUS)
	assert_true(is_equal_approx(AudioServer.get_bus_volume_db(music_idx), GlobalAudioPlayer.DUCK_DB), "背景音樂已調小")
	var peaks_during = await _sample_peaks(music_idx, 1.5)
	print("[TestTool] 播放中 peak：music=%.1f dB, master=%.1f dB" % [peaks_during[0], peaks_during[1]])
	assert_true(peaks_during[1] > peaks_during[0] + 6.0, "語音明顯大於背景音樂")

	await _wait_for_button_enabled(button, 12.0)
	assert_true(not button.disabled, "語音播完後可以按")
	assert_true(not Narration.playing, "語音已結束")
	assert_eq(button.self_modulate.a, 1.0, "播完後按鈕恢復")
	await get_tree().create_timer(0.5).timeout
	assert_true(is_equal_approx(AudioServer.get_bus_volume_db(music_idx), 0.0), "背景音樂恢復")
	var peaks_after = await _sample_peaks(music_idx, 1.5)
	print("[TestTool] 播完後 peak：music=%.1f dB, master=%.1f dB" % [peaks_after[0], peaks_after[1]])
	assert_true(peaks_after[0] > peaks_during[0] + 12.0, "背景音樂實際音量恢復")
	# 只剩音樂時 Master 應該等於音樂 bus；差很多代表有聲音沒走音樂 bus，語音時不會被調小
	assert_true(absf(peaks_after[1] - peaks_after[0]) < 1.0, "遊戲說明頁的聲音都走音樂 bus")

	# 英文：能源介紹頁（返回鍵也要等語音）
	_press_button("StartButton")
	await _wait_for_screen("select_map")
	_select_map_card("coast")
	await _wait_for_screen("coast")
	await get_tree().create_timer(0.5).timeout
	_press_button("WindPowerButton")
	await _wait_for_screen("pre_quiz")
	await get_tree().create_timer(2.0).timeout
	var screen = _super_scene._current_screen
	button = screen.find_child("StartButton", true, false)
	var back_btn = screen.find_child("BackButton", true, false)
	assert_eq(Narration.stream, Narration.EN_CLIPS["wind"], "離岸風電頁播風電語音")
	assert_true(button.disabled and back_btn.disabled, "語音播放中開始鍵與返回鍵都不能按")
	await _wait_for_button_enabled(button, 12.0)
	assert_true(not button.disabled and not back_btn.disabled, "語音播完後開始鍵與返回鍵可以按")
	await _navigate_back_to_welcome()

	# 中文：不播語音、不鎖按鈕
	Lang.set_language(Lang.ZH)
	_press_button("StartButton")
	await _wait_for_screen("intro")
	await get_tree().create_timer(2.0).timeout
	button = _super_scene._current_screen.find_child("StartButton", true, false)
	assert_true(not Narration.playing, "中文模式不播語音")
	assert_true(not button.disabled, "中文模式按鈕直接開放")
	assert_eq(button.self_modulate.a, 1.0, "中文模式按鈕不變淡")
	await _navigate_back_to_welcome()

	Lang.set_language(original_lang)


## 一段時間內 [音樂 bus, Master] 的最大音量
func _sample_peaks(music_idx: int, seconds: float) -> Array:
	var music := -200.0
	var master := -200.0
	var elapsed := 0.0
	while elapsed < seconds:
		await get_tree().create_timer(0.02).timeout
		elapsed += 0.02
		music = max(music, AudioServer.get_bus_peak_volume_left_db(music_idx, 0))
		master = max(master, AudioServer.get_bus_peak_volume_left_db(0, 0))
	return [music, master]


# ─── 導航輔助 ───

## 導航到 quiz 畫面
func _navigate_to_quiz(map_name: String, topic: String) -> void:
	# 找到 topic 對應的按鈕名稱
	var topic_button := ""
	for info in ScreenshotTool.MAP_TOPICS.get(map_name, []):
		if info["topic"] == topic:
			topic_button = info["button"]
			break

	await _wait_for_screen("welcome")
	_press_button("StartButton")
	await _wait_for_screen("intro")
	await _skip_intro()
	await _wait_for_screen("select_map")
	_select_map_card(map_name)
	await _wait_for_screen(map_name)
	await get_tree().create_timer(0.5).timeout
	_press_button(topic_button)
	await _wait_for_screen("pre_quiz")
	_press_button("StartButton")
	await _wait_for_screen("quiz")
	await get_tree().create_timer(0.5).timeout


## 從任何畫面回到 welcome
func _navigate_back_to_welcome() -> void:
	var screen = _super_scene._current_screen
	if screen:
		screen.leave_for_screen("welcome")
	await _wait_for_screen("welcome")
	await get_tree().create_timer(0.5).timeout


## 從 result 回到 welcome
func _navigate_back_to_welcome_from_result() -> void:
	_press_button("MorePolicyButton")
	await _wait_for_screen("policy")
	_press_button("LeaveButton")
	await _wait_for_screen("congrats")
	_press_button("LeaveButton")
	await _wait_for_screen("welcome")
	await get_tree().create_timer(0.5).timeout


## 跳過 intro 所有頁面
func _skip_intro() -> void:
	var screen = _super_scene._current_screen
	var button = screen.find_child("StartButton", true, false)
	if not button:
		return

	while _super_scene._current_screen == screen:
		await _wait_for_button_enabled(button)
		if _super_scene._current_screen != screen:
			break
		button.pressed.emit()
		await get_tree().create_timer(0.3).timeout


## 等待指定畫面
func _wait_for_screen(screen_name: String) -> bool:
	if not _super_scene.screen_instances.has(screen_name):
		push_warning("[TestTool] 未知畫面：%s" % screen_name)
		return false

	var expected = _super_scene.screen_instances[screen_name]
	var timeout := 15.0
	var elapsed := 0.0

	while _super_scene._current_screen != expected and elapsed < timeout:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1

	if elapsed >= timeout:
		push_warning("[TestTool] 等待 %s 超時" % screen_name)
		return false

	await get_tree().create_timer(0.5).timeout
	return true


## 按按鈕
func _press_button(button_name: String) -> void:
	var screen = _super_scene._current_screen
	var button = screen.find_child(button_name, true, false)
	if button:
		button.pressed.emit()
	else:
		push_warning("[TestTool] 找不到按鈕：%s" % button_name)


## 等待按鈕可用
func _wait_for_button_enabled(button: BaseButton, timeout: float = 5.0) -> void:
	var elapsed := 0.0
	while button.disabled and elapsed < timeout:
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05


## 選擇地圖
func _select_map_card(map_name: String) -> void:
	var screen = _super_scene._current_screen
	var container = screen.find_child("HBoxContainer", true, false)
	if not container:
		push_warning("[TestTool] 找不到 HBoxContainer")
		return

	for card in container.get_children():
		if card.get("map_name") == map_name:
			card.button_pressed.emit()
			return

	push_warning("[TestTool] 找不到地圖卡片：%s" % map_name)


# ─── Quiz 按鈕輔助 ───

## 找到正確答案按鈕
func _find_correct_button(container) -> QuizButton:
	for btn in container.get_children():
		if btn is QuizButton and btn.is_correct_answer and not btn.disabled:
			return btn
	return null


## 找到一個錯誤答案按鈕
func _find_wrong_button(container) -> QuizButton:
	for btn in container.get_children():
		if btn is QuizButton and not btn.is_correct_answer and not btn.disabled:
			return btn
	return null


## 找到多個錯誤答案按鈕
func _find_wrong_buttons(container, count: int) -> Array:
	var result: Array = []
	for btn in container.get_children():
		if btn is QuizButton and not btn.is_correct_answer and not btn.disabled:
			result.append(btn)
			if result.size() >= count:
				break
	return result


# ─── 驗證輔助 ───

func assert_eq(actual, expected, msg: String) -> void:
	if actual == expected:
		_pass_count += 1
		print("[TestTool] PASS: %s — %s" % [_current_test, msg])
	else:
		_fail_count += 1
		print("[TestTool] FAIL: %s — %s (expected=%s, actual=%s)" % [_current_test, msg, str(expected), str(actual)])


func assert_true(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("[TestTool] PASS: %s — %s" % [_current_test, msg])
	else:
		_fail_count += 1
		print("[TestTool] FAIL: %s — %s" % [_current_test, msg])
