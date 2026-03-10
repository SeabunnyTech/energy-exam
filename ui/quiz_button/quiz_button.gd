extends Button
class_name QuizButton

signal answered(is_correct:bool)

# 正確答案的旗標 (已修正拼寫錯誤)
@export var is_correct_answer: bool = false

const CORRECT_COLOR := Color(0.2, 0.7, 0.3, 1.0)  # Green
const INCORRECT_COLOR := Color(0.8, 0.3, 0.2, 1.0) # Red


@onready var disabled_stylebox = get_theme_stylebox("disabled")

const _WRONG_BUS := "WrongSFX_PitchComp"

func _ready() -> void:
	pressed.connect(_on_pressed)
	_init_wrong_sfx_bus()

func _init_wrong_sfx_bus() -> void:
	if AudioServer.get_bus_index(_WRONG_BUS) == -1:
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, _WRONG_BUS)
		var fx := AudioEffectPitchShift.new()
		fx.pitch_scale = 1.0 / 1.5  # 補償 1.5x 速度造成的音高上升
		AudioServer.add_bus_effect(idx, fx)
	$wrong_sfx.bus = _WRONG_BUS


# 當按鈕被按下時調用
func _on_pressed():
	if is_correct_answer:
		# 正確：顯示綠色、播放成功音效、通知父節點
		_show_disabled_color(CORRECT_COLOR)
		$success_sfx.play()
		disabled = true
		answered.emit(true)
	else:
		# 錯誤：變紅、播放錯誤音效、再淡出按鈕
		_show_disabled_color(INCORRECT_COLOR)
		disabled = true
		$wrong_sfx.play()
		answered.emit(false)
		var tween = create_tween()
		tween.tween_interval(0.3)
		tween.tween_property(self, "modulate:a", 0.0, 0.3)


func _show_disabled_color(color: Color):
	var base_style = disabled_stylebox
	if base_style and base_style is StyleBoxFlat:
		var new_style: StyleBoxFlat = base_style.duplicate()
		new_style.bg_color = color
		add_theme_stylebox_override("disabled", new_style)


# 從外部調用此函數以重置按鈕狀態
func reset():
	# 恢復預設外觀
	add_theme_stylebox_override("disabled", disabled_stylebox)
	modulate.a = 1.0
	# 重新啟用按鈕，為下一題做準備
	disabled = false
