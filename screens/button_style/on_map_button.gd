extends Button

class_name OnMapButton

@onready var base_style = get_theme_stylebox('normal')

func _ready() -> void:
	pressed.connect(_on_pressed)


# 當按鈕被按下時調用
func _on_pressed():
	
	# 關鍵改動：獲取現有的 disabled 樣式，而不是創建全新的
	
	
	# 檢查樣式是否存在，並且是我們可以修改顏色的 StyleBoxFlat
	if base_style and base_style is StyleBoxFlat:
		# 複製樣式，這樣我們就能在不影響原始主題的情況下修改它
		var new_style: StyleBoxFlat = base_style.duplicate()
		new_style.bg_color = Color.CORNFLOWER_BLUE
		
		# 將修改後的樣式副本套用為 disabled 狀態的覆蓋樣式
		add_theme_stylebox_override("disabled", new_style)
	else:
		# 如果沒有可複製的樣式，提供一個降級方案 (雖然不太可能發生)
		printerr("找不到 'disabled' 狀態的 StyleBoxFlat，無法變更顏色。")

	# 播放音效
	$sfx.play()

	# 回答後禁用按鈕，使其顯示 disabled 狀態的樣式
	disabled = true


# 從外部調用此函數以重置按鈕狀態
func reset():
	# 恢復預設外觀
	add_theme_stylebox_override("disabled", base_style)
	# 重新啟用按鈕，為下一題做準備
	disabled = false
