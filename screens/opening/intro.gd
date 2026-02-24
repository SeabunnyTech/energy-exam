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
var pages: Array = []


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
	# 從 ContentLoader 載入頁面內容
	pages = ContentLoader.get_intro_pages()
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
