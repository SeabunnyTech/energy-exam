extends Node

## ContentLoader - 統一數據管理器
## 負責載入/儲存 content.json，提供 API 給遊戲和編輯器使用

const BUNDLED_PATH = "res://data/content.json"
const USER_PATH = "user://content.json"

var _content: Dictionary = {}
var _is_loaded: bool = false


func _ready():
	_ensure_user_content_exists()
	_load_content()


## 每次啟動都從 res:// 覆蓋 user://，確保內容永遠是最新版
func _ensure_user_content_exists():
	# 從 res:// 複製到 user://
	var bundled_file = FileAccess.open(BUNDLED_PATH, FileAccess.READ)
	if bundled_file == null:
		push_error("[ContentLoader] 無法讀取內建 content.json: %s" % BUNDLED_PATH)
		return

	var content = bundled_file.get_as_text()
	bundled_file.close()

	var user_file = FileAccess.open(USER_PATH, FileAccess.WRITE)
	if user_file == null:
		push_error("[ContentLoader] 無法寫入 user://content.json")
		return

	user_file.store_string(content)
	user_file.close()
	print("[ContentLoader] 已將 content.json 複製到 user://")


## 載入內容
func _load_content():
	var file = FileAccess.open(USER_PATH, FileAccess.READ)
	if file == null:
		push_error("[ContentLoader] 無法讀取 content.json")
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("[ContentLoader] JSON 解析錯誤: %s (行 %d)" % [json.get_error_message(), json.get_error_line()])
		return

	_content = json.data
	_is_loaded = true
	print("[ContentLoader] 內容載入完成")


## 儲存內容到 user://
func save_content() -> bool:
	var json_text = JSON.stringify(_content, "\t")

	var file = FileAccess.open(USER_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[ContentLoader] 無法寫入 content.json")
		return false

	file.store_string(json_text)
	file.close()
	print("[ContentLoader] 內容已儲存")
	return true


## 重新載入內容（例如編輯後刷新）
func reload_content():
	_load_content()


## 重置為內建預設內容
func reset_to_default():
	# 刪除 user:// 版本
	if FileAccess.file_exists(USER_PATH):
		DirAccess.remove_absolute(USER_PATH)
	# 重新複製並載入
	_ensure_user_content_exists()
	_load_content()


## 依目前語系取欄位：英文時優先讀 `<key>_en`，缺少時退回中文
## （後台編輯器只編中文，因此 get_/set_ 系列 API 維持讀寫原欄位）
func _localized(data: Dictionary, key: String, default = ""):
	if Lang.current != Lang.ZH:
		var localized_key = "%s_%s" % [key, Lang.current]
		if data.has(localized_key):
			return data[localized_key]
	return data.get(key, default)


# ===== Intro Pages API =====

func get_intro_pages() -> Array:
	if not _is_loaded or not _content.has("intro"):
		return []
	return _content["intro"].get("pages", [])


## 遊戲畫面用：依目前語系取得介紹頁
func get_localized_intro_pages() -> Array:
	if not _is_loaded or not _content.has("intro"):
		return []
	return _localized(_content["intro"], "pages", [])


func set_intro_pages(pages: Array):
	if not _content.has("intro"):
		_content["intro"] = {}
	_content["intro"]["pages"] = pages


func get_intro_page(index: int) -> String:
	var pages = get_intro_pages()
	if index < 0 or index >= pages.size():
		return ""
	return pages[index]


func set_intro_page(index: int, text: String):
	var pages = get_intro_pages()
	if index >= 0 and index < pages.size():
		pages[index] = text
		set_intro_pages(pages)


# ===== Topics API =====

func get_topic_data(topic: String) -> Dictionary:
	if not _is_loaded or not _content.has("topics"):
		return {}
	return _content["topics"].get(topic, {})


func get_topic_title(topic: String) -> String:
	return get_topic_data(topic).get("title", "")


func get_topic_guide(topic: String) -> String:
	return get_topic_data(topic).get("guide", "")


func get_topic_policy(topic: String) -> String:
	return get_topic_data(topic).get("policy", "")


func set_topic_data(topic: String, data: Dictionary):
	if not _content.has("topics"):
		_content["topics"] = {}
	_content["topics"][topic] = data


func set_topic_title(topic: String, title: String):
	var data = get_topic_data(topic)
	data["title"] = title
	set_topic_data(topic, data)


func set_topic_guide(topic: String, guide: String):
	var data = get_topic_data(topic)
	data["guide"] = guide
	set_topic_data(topic, data)


func set_topic_policy(topic: String, policy: String):
	var data = get_topic_data(topic)
	data["policy"] = policy
	set_topic_data(topic, data)


## 取得特定地圖+主題的標題和引導文字（支援覆寫）
func get_topic_title_and_guide(map_name: String, topic: String) -> Dictionary:
	var data = get_topic_data(topic)
	var result = {
		"title": _localized(data, "title"),
		"guide": _localized(data, "guide")
	}

	# 檢查是否有地圖特定的覆寫
	if _content.has("topic_overrides"):
		var overrides = _content["topic_overrides"]
		if overrides.has(map_name) and overrides[map_name].has(topic):
			var override_data = overrides[map_name][topic]
			if override_data.has("title"):
				result["title"] = _localized(override_data, "title")
			if override_data.has("guide"):
				result["guide"] = _localized(override_data, "guide")

	# 容錯處理
	if result["title"] == "":
		result["title"] = "[缺少標題] map=%s, topic=%s" % [map_name, topic]
	if result["guide"] == "":
		result["guide"] = "[缺少引導文字]"

	return result


func set_topic_override(map_name: String, topic: String, title: String, guide: String):
	if not _content.has("topic_overrides"):
		_content["topic_overrides"] = {}
	if not _content["topic_overrides"].has(map_name):
		_content["topic_overrides"][map_name] = {}
	_content["topic_overrides"][map_name][topic] = {
		"title": title,
		"guide": guide
	}


## 取得政策文字
func get_policy(map_name: String, topic: String) -> String:
	# 政策文字不需要按地圖區分，直接用 topic
	var policy = _localized(get_topic_data(topic), "policy")
	if policy == "":
		push_warning("[ContentLoader] 找不到政策: map=%s, topic=%s" % [map_name, topic])
	return policy


# ===== Questions API =====

func get_all_topic_keys() -> Array:
	if not _is_loaded or not _content.has("questions"):
		return []
	return _content["questions"].keys()


func get_questions(topic: String) -> Array:
	if not _is_loaded or not _content.has("questions"):
		return []
	return _content["questions"].get(topic, [])


func set_questions(topic: String, questions: Array):
	if not _content.has("questions"):
		_content["questions"] = {}
	_content["questions"][topic] = questions


func get_question(topic: String, index: int) -> Dictionary:
	var questions = get_questions(topic)
	if index < 0 or index >= questions.size():
		return {}
	return questions[index]


func set_question(topic: String, index: int, question: Dictionary):
	var questions = get_questions(topic)
	if index >= 0 and index < questions.size():
		questions[index] = question
		set_questions(topic, questions)


func add_question(topic: String, question: Dictionary):
	var questions = get_questions(topic)
	# 自動分配 ID
	var max_id = 0
	for q in questions:
		if q.has("id") and q["id"] > max_id:
			max_id = q["id"]
	question["id"] = max_id + 1
	questions.append(question)
	set_questions(topic, questions)


func delete_question(topic: String, index: int):
	var questions = get_questions(topic)
	if index >= 0 and index < questions.size():
		questions.remove_at(index)
		set_questions(topic, questions)


## 將問題轉換為 QuestionReader 兼容格式
func get_questions_for_quiz(topic: String) -> Array:
	var questions = get_questions(topic)
	var result = []

	for q in questions:
		var options_formatted = []
		var options = _localized(q, "options", [])
		# 答案編號共用中文題目，翻譯的選項數量不同時退回中文避免答案錯位
		if options.size() != q.get("options", []).size():
			push_warning("[ContentLoader] %s 題目「%s」的翻譯選項數量不符，改用中文" % [topic, q.get("title", "")])
			options = q.get("options", [])
		for i in range(options.size()):
			options_formatted.append("%d.%s" % [i + 1, options[i]])

		result.append({
			"標題": _localized(q, "title"),
			"內容": _localized(q, "content"),
			"答案": q.get("answer", 1),
			"選項": options_formatted
		})

	return result


# ===== Utility =====

func get_all_topics() -> Dictionary:
	if not _is_loaded or not _content.has("topics"):
		return {}
	return _content["topics"]


func get_raw_content() -> Dictionary:
	return _content
