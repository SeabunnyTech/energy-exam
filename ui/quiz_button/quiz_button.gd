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
	var sfx = $wrong_sfx
	
	# 關鍵改動：獲取現有的 disabled 樣式，而不是創建全新的
	var base_style = disabled_stylebox
	
	# 檢查樣式是否存在，並且是我們可以修改顏色的 StyleBoxFlat
	if base_style and base_style is StyleBoxFlat:
		# 複製樣式，這樣我們就能在不影響原始主題的情況下修改它
		var new_style: StyleBoxFlat = base_style.duplicate()
		
		# 根據答案正確與否，設定副本的背景顏色
		if is_correct_answer:
			sfx = $success_sfx
			new_style.bg_color = CORRECT_COLOR
		else:
			new_style.bg_color = INCORRECT_COLOR
		
		# 將修改後的樣式副本套用為 disabled 狀態的覆蓋樣式
		add_theme_stylebox_override("disabled", new_style)
	else:
		# 如果沒有可複製的樣式，提供一個降級方案 (雖然不太可能發生)
		printerr("找不到 'disabled' 狀態的 StyleBoxFlat，無法變更顏色。")

	# 播放音效
	sfx.play()
	# 發送信號，告知父節點答案是否正確
	answered.emit(is_correct_answer)
	
	# 回答後禁用按鈕，使其顯示 disabled 狀態的樣式
	disabled = true


# 從外部調用此函數以重置按鈕狀態
func reset():
	# 恢復預設外觀
	add_theme_stylebox_override("disabled", disabled_stylebox)
	# 重新啟用按鈕，為下一題做準備
	disabled = false
