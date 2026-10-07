extends Node

## Lang - 語系管理（中文 / English）
## 介面文字集中在 UI_TEXT；題目、引導、政策等內容放在 content.json 的 `<欄位>_en`
## 預設語系可由命令列指定：godot --lang en（截圖工具可搭配：godot --screenshots all --lang en）

signal language_changed(lang: String)

const ZH := "zh"
const EN := "en"

## 回到首頁時恢復的語系
var default_language: String = ZH
var current: String = ZH


func _ready() -> void:
	var args = OS.get_cmdline_args()
	var i = args.find("--lang")
	if i != -1 and i + 1 < args.size() and args[i + 1] in [ZH, EN]:
		default_language = args[i + 1]
	current = default_language


func set_language(lang: String) -> void:
	if lang == current:
		return
	current = lang
	print("[Lang] 切換語系：%s" % lang)
	language_changed.emit(lang)


func toggle() -> void:
	set_language(ZH if current == EN else EN)


func reset_to_default() -> void:
	set_language(default_language)


func is_en() -> bool:
	return current == EN


## 取得介面文字
func t(key: String) -> String:
	if not UI_TEXT.has(key):
		push_warning("[Lang] 缺少介面文字：%s" % key)
		return key
	var entry: Dictionary = UI_TEXT[key]
	return entry.get(current, entry[ZH])


# ===== 字級調整 =====

## 中文維持場景原本的字級；英文從 en_max 往下縮小，直到文字放得進元件的版面範圍
## （en_max == en_min 即為英文固定字級）
func fit_font(control: Control, en_max: int, en_min: int = 20) -> void:
	var settings: LabelSettings = control.label_settings if control is Label else null
	if not control.has_meta("zh_font_size"):
		if settings:
			# 同一場景的多個實例共用 LabelSettings，複製一份避免互相影響
			settings = settings.duplicate()
			control.label_settings = settings
		control.set_meta("zh_font_size", settings.font_size if settings else control.get_theme_font_size("font_size"))

	var font_size: int = control.get_meta("zh_font_size")
	if is_en():
		font_size = _largest_fitting_size(control, settings, en_max, en_min)

	if settings:
		settings.font_size = font_size
	else:
		control.add_theme_font_size_override("font_size", font_size)


func _largest_fitting_size(control: Control, settings: LabelSettings, max_size: int, min_size: int) -> int:
	var font: Font = settings.font if settings and settings.font else control.get_theme_font("font")
	var style: StyleBox = control.get_theme_stylebox("normal")
	var box: Vector2 = _layout_size(control) - style.get_minimum_size()
	var wraps: bool = control.autowrap_mode != TextServer.AUTOWRAP_OFF
	var line_spacing: float = float(control.get_theme_constant("line_spacing")) if control is Label else 0.0
	if settings:
		line_spacing += settings.line_spacing

	for font_size in range(max_size, min_size, -2):
		var text_size := font.get_multiline_string_size(control.text, HORIZONTAL_ALIGNMENT_LEFT, box.x if wraps else -1.0, font_size)
		var line_count: int = roundi(text_size.y / font.get_height(font_size))
		var height: float = text_size.y + line_spacing * max(line_count - 1, 0)
		if text_size.x <= box.x and height <= box.y:
			return font_size
	return min_size


## 依語系切換版面範圍，anchors 順序為 [左, 上, 右, 下]（offset 不變）
func set_anchors(control: Control, zh_anchors: Array, en_anchors: Array) -> void:
	var anchors := en_anchors if is_en() else zh_anchors
	for side in 4:
		control.set_anchor(side, anchors[side], true, false)


## 元件依 anchor/offset 應有的大小（文字溢出時 Label 會被撐大，不能直接用 size）
func _layout_size(control: Control) -> Vector2:
	if control.get_parent() is Container:
		return control.size
	var parent := control.get_parent_area_size()
	return Vector2(
		(control.anchor_right - control.anchor_left) * parent.x + control.offset_right - control.offset_left,
		(control.anchor_bottom - control.anchor_top) * parent.y + control.offset_bottom - control.offset_top
	)


# ===== 介面文字 =====

const UI_TEXT := {
	# 首頁
	"start": {"zh": "開始", "en": "Start"},
	"switch_language": {"zh": "English", "en": "中文"},

	# 遊戲說明頁
	"intro_title": {"zh": "歡迎來到Energy Quiz 問答遊戲", "en": "Welcome to the Energy Quiz!"},
	"intro_hint": {
		"zh": "完成後您將可獲得精美照相圖框，可自製個人化照片喔~",
		"en": "After completing the quiz, you will receive a beautifully designed photo frame to create your own personalized picture.",
	},
	"next_page": {"zh": "下一頁", "en": "Next"},

	# 選擇地圖
	"select_map_hint": {
		"zh": "台灣各地蘊藏許多再生能源，各有不同的發展潛力，請點選您想要挑戰的地圖。",
		"en": "Every region of Taiwan has its own renewable energy potential. Choose the map you want to challenge!",
	},
	"select_map_button": {"zh": "選擇關卡", "en": "Select"},
	"map_coast_title": {"zh": "濱海城市", "en": "Coastal Cities"},
	"map_coast_guide": {
		"zh": "臨海城市風場佳、日照足\n配置離岸風電與地面/屋頂太陽能，搭配科技儲能穩定供電",
		"en": "Strong winds and plenty of sunshine make coastal cities ideal for offshore wind, solar power and energy storage.",
	},
	"map_west_title": {"zh": "西部平原", "en": "Western Plains"},
	"map_west_guide": {
		"zh": "西部平原地勢開闊、灌溉水系多，適合地面太陽能與小水力發電，並以儲能調節尖離峰。",
		"en": "Open terrain and irrigation channels suit ground-mounted solar and small hydropower, with storage balancing demand.",
	},
	"map_east_title": {"zh": "東部縱谷", "en": "Eastern Rift Valley"},
	"map_east_guide": {
		"zh": "東部縱谷具地熱潛力，可發展地熱發電，結合屋頂太陽能與儲能提升韌性。",
		"en": "Rich in geothermal potential, the valley also uses rooftop solar and energy storage to boost energy resilience.",
	},
	"loading": {"zh": "載入中", "en": "Loading"},

	# 地圖上的設施按鈕
	"facility_wind": {"zh": "離岸風電", "en": "Offshore Wind Power"},
	"facility_solar_ground": {"zh": "地面型太陽能板", "en": "Ground-mounted Solar"},
	"facility_solar_roof": {"zh": "屋頂型太陽能板", "en": "Rooftop Solar"},
	"facility_energy_storage": {"zh": "儲能設施", "en": "Energy Storage"},
	"facility_geothermal": {"zh": "地熱發電", "en": "Geothermal Power"},
	"facility_hydro": {"zh": "小水力發電", "en": "Small Hydropower"},
	"facility_hydro_west": {"zh": "水力發電", "en": "Small Hydropower"},

	# 結果與政策
	"result_title": {"zh": "挑戰完成!", "en": "Challenge Complete!"},
	"result_score": {"zh": "您答對了 %d 題", "en": "You got %d correct"},
	"result_total_score": {"zh": "累計答對 %d 題", "en": "Total correct: %d"},
	"more_policy": {"zh": "認識更多政策", "en": "Learn About the Policy"},
	"back_to_map": {"zh": "還想了解其他設施", "en": "Explore Other Facilities"},
	"finish": {"zh": "完成", "en": "Finish"},

	# 完成頁
	"congrats_title": {"zh": "恭喜你完成挑戰!", "en": "Congratulations on completing the challenge!"},
	"congrats_guide": {
		"zh": "請掃描QR Code \n選擇喜愛圖框上傳照片分享好友!",
		"en": "Scan the QR code, pick your favorite frame, and share your photo with friends.",
	},
}
