## ScreenshotTool - 內建截圖工具
## 透過觸發按鈕模擬正常遊戲流程進行截圖
## 用法：
##   godot --screenshots all                → 所有地圖、所有能源
##   godot --screenshots coast              → 海岸地圖所有能源
##   godot --screenshots coast:wind         → 海岸地圖風力
##   godot --screenshots coast,east         → 海岸 + 東部所有能源
##   godot --screenshots coast:wind,east:geothermal  → 指定組合
##   godot --screenshots pre_quiz           → 只截所有 pre_quiz 畫面
##   godot --screenshots policy             → 只截所有 policy 畫面
##   godot --screenshots pre_quiz,policy    → 只截 pre_quiz + policy
##   godot --screenshots pre_quiz:wind      → 只截 wind 主題的 pre_quiz
##   godot --screenshots policy:solar_ground → 只截 solar_ground 主題的 policy
## 支援的畫面類型篩選：
##   welcome, energy_goal, intro, select_map, map, pre_quiz, quiz, result, policy, congrats
extends Node


# 各地圖的能源主題與對應按鈕
const MAP_TOPICS: Dictionary = {
	"coast": [
		{"topic": "wind", "button": "WindPowerButton"},
		{"topic": "solar_ground", "button": "GroundSolarButton"},
		{"topic": "solar_roof", "button": "RoofSolarButton"},
		{"topic": "energy_storage", "button": "EnergyStorageButton"},
	],
	"west": [
		{"topic": "solar_ground", "button": "GroundSolarButton"},
		{"topic": "hydro", "button": "HydroPowerButton"},
		{"topic": "energy_storage", "button": "EnergyStorageButton"},
	],
	"east": [
		{"topic": "geothermal", "button": "GeothermalButton"},
		{"topic": "hydro", "button": "HydroPowerButton"},
		{"topic": "solar_roof", "button": "RoofSolarButton"},
		{"topic": "energy_storage", "button": "EnergyStorageButton"},
	],
}

# 畫面類型篩選關鍵字（用於 --screenshots pre_quiz 等）
const SCREEN_TYPES: Array[String] = [
	"welcome", "energy_goal", "intro", "select_map", "map",
	"pre_quiz", "quiz", "result", "policy", "congrats",
]

# 要執行的 map+topic 組合清單
var _runs: Array[Dictionary] = []

# 畫面類型篩選（空 = 全部截）
var _screen_filter: Array[String] = []

# 已截過的畫面（避免重複）
var _captured: Dictionary = {}

# 預計算的全域編號（按 all 順序）：screen_name → number
var _all_numbering: Dictionary = {}

# 實際截圖張數（用於結束統計）
var _capture_count: int = 0

# 預期截圖總數（用於提前結束）
var _expected_captures: int = 0

var _is_active: bool = false
var _super_scene: Node = null


func _ready() -> void:
	var args = OS.get_cmdline_args()
	var screenshots_arg := ""

	for i in range(args.size()):
		if args[i] == "--screenshots" and i + 1 < args.size():
			screenshots_arg = args[i + 1]
			break

	if screenshots_arg.is_empty():
		return

	_is_active = true
	print("[ScreenshotTool] 截圖模式啟動，參數：%s" % screenshots_arg)

	_parse_args(screenshots_arg)

	if _runs.is_empty():
		push_warning("[ScreenshotTool] 沒有有效的截圖目標，結束")
		await get_tree().create_timer(0.1).timeout
		get_tree().quit()
		return

	print("[ScreenshotTool] 截圖排程：%d 組" % _runs.size())
	for run in _runs:
		print("  - %s : %s" % [run["map"], run["topic"]])
	if not _screen_filter.is_empty():
		print("[ScreenshotTool] 篩選畫面類型：%s" % str(_screen_filter))

	await get_tree().create_timer(1.0).timeout
	_start_capture()


## 將所有地圖所有能源加入 _runs
func _add_all_runs() -> void:
	for map_name in MAP_TOPICS:
		for info in MAP_TOPICS[map_name]:
			_runs.append({"map": map_name, "topic": info["topic"], "button": info["button"]})


## 將指定主題涉及的所有地圖加入 _runs（不重複）
func _add_runs_for_topic(topic: String) -> void:
	for map_name in MAP_TOPICS:
		for info in MAP_TOPICS[map_name]:
			if info["topic"] == topic:
				var run = {"map": map_name, "topic": topic, "button": info["button"]}
				if not _has_run(run):
					_runs.append(run)


## 檢查 _runs 中是否已有相同的 map+topic 組合
func _has_run(run: Dictionary) -> bool:
	for existing in _runs:
		if existing["map"] == run["map"] and existing["topic"] == run["topic"]:
			return true
	return false


## 解析命令列參數，建立 _runs 清單與 _screen_filter
func _parse_args(screenshots_arg: String) -> void:
	if screenshots_arg.to_lower() == "all":
		_add_all_runs()
		return

	# 先收集純篩選類型（不帶冒號的 screen type），最後再決定是否需要 _add_all_runs
	var filter_only_types: Array[String] = []

	for part in screenshots_arg.split(","):
		var trimmed = part.strip_edges()

		if ":" in trimmed:
			var parts = trimmed.split(":")
			var left = parts[0]
			var right = parts[1]

			if SCREEN_TYPES.has(left) and MAP_TOPICS.has(right):
				# screen_type:map_name 格式（如 map:west, map:coast）
				if not _screen_filter.has(left):
					_screen_filter.append(left)
				for info in MAP_TOPICS[right]:
					_runs.append({"map": right, "topic": info["topic"], "button": info["button"]})
			elif SCREEN_TYPES.has(left):
				# screen_type:topic 格式（如 pre_quiz:hydro, policy:solar_ground）
				if not _screen_filter.has(left):
					_screen_filter.append(left)
				_add_runs_for_topic(right)
			elif MAP_TOPICS.has(left):
				# map:topic 格式（如 coast:wind）
				for info in MAP_TOPICS[left]:
					if info["topic"] == right:
						_runs.append({"map": left, "topic": right, "button": info["button"]})
						break
			else:
				push_warning("[ScreenshotTool] 未知參數：%s" % trimmed)

		elif SCREEN_TYPES.has(trimmed):
			# 純畫面類型篩選（如 select_map, pre_quiz）
			if not _screen_filter.has(trimmed):
				_screen_filter.append(trimmed)
			filter_only_types.append(trimmed)

		elif MAP_TOPICS.has(trimmed):
			# 地圖全部能源（如 coast）
			for info in MAP_TOPICS[trimmed]:
				_runs.append({"map": trimmed, "topic": info["topic"], "button": info["button"]})

		else:
			push_warning("[ScreenshotTool] 未知參數：%s" % trimmed)

	# 如果只有純篩選類型而沒有其他帶 topic 的 runs，才加入全部 runs
	if not filter_only_types.is_empty() and _runs.is_empty():
		_add_all_runs()


## 預計算全域編號（模擬 all 的完整流程順序）
func _build_numbering() -> void:
	var idx := 0
	var seen: Dictionary = {}

	# 取得 intro 頁數
	var intro_page_count: int = ContentLoader.get_intro_pages().size()

	# 模擬 all 流程中每一輪的截圖順序
	var all_runs: Array[Dictionary] = []
	for map_name in MAP_TOPICS:
		for info in MAP_TOPICS[map_name]:
			all_runs.append({"map": map_name, "topic": info["topic"]})

	for run in all_runs:
		var map_name: String = run["map"]
		var topic: String = run["topic"]
		var prefix: String = "%s_%s" % [map_name, topic]

		# Opening（只計一次）
		if not seen.has("welcome"):
			seen["welcome"] = true
			idx += 1; _all_numbering["welcome"] = idx
		if not seen.has("intro"):
			seen["intro"] = true
			for p in range(intro_page_count):
				idx += 1; _all_numbering["intro_%d" % (p + 1)] = idx
		if not seen.has("select_map"):
			seen["select_map"] = true
			idx += 1; _all_numbering["select_map"] = idx

		# 地圖畫面（每張地圖只計一次）
		if not seen.has(map_name):
			seen[map_name] = true
			idx += 1; _all_numbering[map_name] = idx

		# 測驗流程（每個 map+topic 都是唯一的）
		idx += 1; _all_numbering["%s_pre_quiz" % prefix] = idx
		for q in range(3):
			idx += 1; _all_numbering["%s_quiz_%d" % [prefix, q + 1]] = idx
		idx += 1; _all_numbering["%s_result" % prefix] = idx
		idx += 1; _all_numbering["%s_policy" % prefix] = idx

		# Congrats（只計一次）
		if not seen.has("congrats"):
			seen["congrats"] = true
			idx += 1; _all_numbering["congrats"] = idx

	print("[ScreenshotTool] 全域編號已建立，共 %d 個位置" % idx)


## 計算預期截圖總數
func _calc_expected_captures() -> int:
	var count := 0
	var seen: Dictionary = {}
	var intro_page_count: int = ContentLoader.get_intro_pages().size()

	for run in _runs:
		var map_name: String = run["map"]

		# 共用畫面（只計一次）
		if not seen.has("welcome") and _should_capture("welcome"):
			seen["welcome"] = true; count += 1
		if not seen.has("intro") and _should_capture("intro"):
			seen["intro"] = true; count += intro_page_count
		if not seen.has("select_map") and _should_capture("select_map"):
			seen["select_map"] = true; count += 1
		if not seen.has(map_name) and _should_capture("map"):
			seen[map_name] = true; count += 1

		# 每個 map+topic 的測驗流程
		if _should_capture("pre_quiz"): count += 1
		if _should_capture("quiz"): count += 3
		if _should_capture("result"): count += 1
		if _should_capture("policy"): count += 1

		if not seen.has("congrats") and _should_capture("congrats"):
			seen["congrats"] = true; count += 1

	return count


## 開始截圖流程
func _start_capture() -> void:
	_super_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)

	if not _super_scene or not _super_scene.has_method("goto_screen"):
		push_error("[ScreenshotTool] 找不到 SuperScene，結束")
		get_tree().quit(1)
		return

	_build_numbering()
	_expected_captures = _calc_expected_captures()
	print("[ScreenshotTool] 預期截圖：%d 張" % _expected_captures)
	DirAccess.make_dir_recursive_absolute("res://screenshots")

	for i in range(_runs.size()):
		if _is_done():
			break
		var run = _runs[i]
		var is_last: bool = (i == _runs.size() - 1)
		print("[ScreenshotTool] ====== 第 %d/%d 組：%s / %s ======" % [i + 1, _runs.size(), run["map"], run["topic"]])
		await _run_cycle(run["map"], run["topic"], run["button"], is_last)

	print("[ScreenshotTool] 全部截圖完成，共 %d 張" % _capture_count)
	OS.shell_open(ProjectSettings.globalize_path("res://screenshots"))
	get_tree().quit()


## 是否已截完所有需要的圖
func _is_done() -> bool:
	return _expected_captures > 0 and _capture_count >= _expected_captures


## 執行一輪完整的遊戲流程（opening → map → quiz flow → congrats）
func _run_cycle(map_name: String, topic: String, topic_button: String, is_last: bool) -> void:
	# === 開場畫面（重複不截圖，但仍需導航） ===
	var needs: bool

	needs = _needs_capture_once("welcome", "welcome")
	await _wait_for_screen("welcome", needs)
	if needs: await _capture_once("welcome")
	if _is_done(): return
	_press_button("StartButton")

	# Intro（多頁）
	var should_capture_intro: bool = not _captured.has("intro") and _should_capture("intro")
	await _wait_for_screen("intro", should_capture_intro)
	if should_capture_intro:
		_captured["intro"] = true
	await _handle_intro(should_capture_intro)
	if _is_done(): return

	# 選擇地圖
	needs = _needs_capture_once("select_map", "select_map")
	await _wait_for_screen("select_map", needs)
	if needs: await _capture_once("select_map")
	if _is_done(): return
	_select_map_card(map_name)

	# 地圖畫面（screen_type = "map"）
	needs = _needs_capture_once(map_name, "map")
	await _wait_for_screen(map_name, needs)
	if needs: await _capture_once(map_name)
	if _is_done(): return
	_press_button(topic_button)

	# === 測驗流程（每個 map+topic 都是唯一的） ===
	var prefix: String = "%s_%s" % [map_name, topic]

	needs = _should_capture("pre_quiz")
	await _wait_for_screen("pre_quiz", needs)
	if needs: await _numbered_capture("%s_pre_quiz" % prefix)
	if _is_done(): return
	_press_button("StartButton")

	await _wait_for_screen("quiz", _should_capture("quiz"))
	await _handle_quiz(prefix)
	if _is_done(): return

	needs = _should_capture("result")
	await _wait_for_screen("result", needs)
	if needs: await _numbered_capture("%s_result" % prefix)
	if _is_done(): return
	_press_button("MorePolicyButton")

	needs = _should_capture("policy")
	await _wait_for_screen("policy", needs)
	if needs: await _numbered_capture("%s_policy" % prefix)
	if _is_done(): return
	_press_button("LeaveButton")

	# 恭喜畫面
	needs = _needs_capture_once("congrats", "congrats")
	await _wait_for_screen("congrats", needs)
	if needs: await _capture_once("congrats")
	if _is_done(): return

	# 如果不是最後一組，按按鈕回到 welcome 繼續下一輪
	if not is_last:
		_press_button("LeaveButton")


# ─── 截圖輔助 ───

## 檢查該畫面類型是否應該截圖（根據 _screen_filter）
func _should_capture(screen_type: String) -> bool:
	return _screen_filter.is_empty() or _screen_filter.has(screen_type)


## 檢查 capture_once 類型是否需要截圖（未截過 + 通過篩選）
func _needs_capture_once(capture_name: String, screen_type: String) -> bool:
	return not _captured.has(capture_name) and _should_capture(screen_type)


## 帶編號的截圖（使用預計算的全域編號）
func _numbered_capture(capture_name: String) -> void:
	if _all_numbering.has(capture_name):
		var num: int = _all_numbering[capture_name]
		_capture_count += 1
		await _do_capture("%03d_%s" % [num, capture_name])
	else:
		push_warning("[ScreenshotTool] 找不到編號：%s，使用 999" % capture_name)
		_capture_count += 1
		await _do_capture("999_%s" % capture_name)


## 只截一次（重複畫面跳過）
func _capture_once(capture_name: String) -> void:
	if _captured.has(capture_name):
		return
	_captured[capture_name] = true
	await _numbered_capture(capture_name)


## 實際執行截圖儲存
func _do_capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	var file_path: String = "res://screenshots/%s.png" % filename
	var error = image.save_png(file_path)
	if error == OK:
		print("[ScreenshotTool] 截圖已儲存：%s" % file_path)
	else:
		push_error("[ScreenshotTool] 儲存失敗：%s (error: %d)" % [file_path, error])


# ─── 導航輔助 ───

## 等待指定畫面成為當前畫面
## needs_capture=true 時等待動畫完成再截圖，false 時只等最小時間即可操作
func _wait_for_screen(screen_name: String, needs_capture: bool = true) -> bool:
	if not _super_scene.screen_instances.has(screen_name):
		push_warning("[ScreenshotTool] 未知畫面：%s" % screen_name)
		return false

	var expected = _super_scene.screen_instances[screen_name]
	var timeout := 15.0
	var elapsed := 0.0

	while _super_scene._current_screen != expected and elapsed < timeout:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1

	if elapsed >= timeout:
		push_warning("[ScreenshotTool] 等待 %s 超時" % screen_name)
		return false

	# 需要截圖：等動畫完成；不需要：只等按鈕可用的最小時間
	var wait_time := 2.5 if needs_capture else 0.5
	await get_tree().create_timer(wait_time).timeout
	return true


## 在當前畫面中找到按鈕並觸發 pressed
func _press_button(button_name: String) -> void:
	var screen = _super_scene._current_screen
	var button = screen.find_child(button_name, true, false)
	if button:
		print("[ScreenshotTool] 按下按鈕：%s" % button_name)
		button.pressed.emit()
	else:
		push_warning("[ScreenshotTool] 找不到按鈕：%s" % button_name)


## 等待按鈕變為可用狀態
func _wait_for_button_enabled(button: BaseButton, timeout: float = 5.0) -> void:
	var elapsed := 0.0
	while button.disabled and elapsed < timeout:
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05


## 在選擇地圖畫面中找到對應的地圖卡片並觸發
func _select_map_card(map_name: String) -> void:
	var screen = _super_scene._current_screen
	var container = screen.find_child("HBoxContainer", true, false)
	if not container:
		push_warning("[ScreenshotTool] 找不到 HBoxContainer")
		return

	for card in container.get_children():
		if card.get("map_name") == map_name:
			print("[ScreenshotTool] 選擇地圖：%s" % map_name)
			card.button_pressed.emit()
			return

	push_warning("[ScreenshotTool] 找不到地圖卡片：%s" % map_name)


# ─── 特殊畫面處理 ───

## Intro 多頁處理：每頁截圖後翻頁
func _handle_intro(should_capture: bool) -> void:
	var screen = _super_scene._current_screen
	var button = screen.find_child("StartButton", true, false)
	if not button:
		push_warning("[ScreenshotTool] intro 找不到 StartButton")
		return

	var page := 1
	while _super_scene._current_screen == screen:
		await _wait_for_button_enabled(button)
		if _super_scene._current_screen != screen:
			break

		if should_capture:
			await _numbered_capture("intro_%d" % page)

		print("[ScreenshotTool] intro 第 %d 頁，按下按鈕" % page)
		button.pressed.emit()
		page += 1
		await get_tree().create_timer(0.3 if not should_capture else 0.6).timeout


## Quiz 多題處理：每題截圖後作答
func _handle_quiz(prefix: String) -> void:
	var screen = _super_scene._current_screen
	var needs: bool = _should_capture("quiz")

	for i in range(3):
		if _super_scene._current_screen != screen:
			break

		# 等待題目 fade in（不截圖時縮短）
		await get_tree().create_timer(0.5 if needs else 0.2).timeout

		if needs:
			await _numbered_capture("%s_quiz_%d" % [prefix, i + 1])

		# 找到正確答案按鈕並作答
		var container = screen.answer_container
		if container:
			for child in container.get_children():
				if child is QuizButton and child.is_correct_answer and not child.disabled:
					print("[ScreenshotTool] 作答第 %d 題" % (i + 1))
					child.pressed.emit()
					break

		# 等待答題動畫 + 下一題（不截圖時縮短）
		await get_tree().create_timer(1.5 if needs else 0.8).timeout
