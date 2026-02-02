extends BaseScreen


@onready var button = $StartButton
@onready var title = $Title
@onready var guide = $GuideLabel
@onready var page_dots = $PageDots

var dot_style_active: StyleBoxFlat
var dot_style_inactive: StyleBoxFlat

var beat_tween: Tween
var initial_button_position_y: float

var current_page: int = 0
var pages: Array[String] = [
	"歡迎參與能源轉型互動體驗遊戲！
本遊戲結合聲光效果的數位互動展具，
透過操作與問答，帶領你認識我國能源轉型的多元面向，
了解各類再生能源的特色，
以及政府在推動過程中所採取的政策與解決方案，
一起思考如何透過能源轉型減少溫室氣體排放。",

	"體驗過程中，你可自由選擇不同的地圖環境，
例如臨海城市、西部平原或東部淺山，
並搭配不同的能源設施，如離岸風電、陸域風電、
水力發電、燃煤發電或屋頂型太陽光電。
每一種能源皆設計有專屬的互動問答模組，
讓你在遊戲中輕鬆了解我國能源發展現況與相關政策重點。",

	"完成遊戲後，還可使用拍照圖框功能，
透過 QR Code 下載或分享專屬紀念照片。
完成指定任務即可獲得精美贈品一份，
歡迎一起來挑戰，成為能源轉型達人！"
]


func _ready():
	button.pressed.connect(_on_button_pressed)
	initial_button_position_y = button.position.y
	ui_to_fade = [self, title, guide, button]

	dot_style_active = StyleBoxFlat.new()
	dot_style_active.bg_color = Color(0.2, 0.2, 0.2, 1)
	dot_style_active.set_corner_radius_all(12)

	dot_style_inactive = StyleBoxFlat.new()
	dot_style_inactive.bg_color = Color(0.7, 0.7, 0.7, 1)
	dot_style_inactive.set_corner_radius_all(12)

	reset()


func on_pre_enter(_param):
	current_page = 0
	guide.modulate.a = 1.0
	_update_page()


func _update_page():
	guide.text = pages[current_page]

	for i in page_dots.get_child_count():
		var dot = page_dots.get_child(i)
		if i == current_page:
			dot.add_theme_stylebox_override("panel", dot_style_active)
		else:
			dot.add_theme_stylebox_override("panel", dot_style_inactive)

	if current_page < pages.size() - 1:
		button.text = "下一步"
	else:
		button.text = "開始"


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


func _on_button_pressed():
	if current_page < pages.size() - 1:
		_transition_to_next_page()
	else:
		leave_for_screen("select_map")


func _transition_to_next_page():
	button.disabled = true

	var tween = create_tween()
	tween.tween_property(guide, "modulate:a", 0.0, 0.2)
	tween.tween_callback(_go_to_next_page)
	tween.tween_property(guide, "modulate:a", 1.0, 0.2)
	tween.tween_callback(func(): button.disabled = false)


func _go_to_next_page():
	current_page += 1
	_update_page()
