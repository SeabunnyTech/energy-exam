@tool
extends Button

class_name OnMapButton

# 對話框設定
@export_group("Speech Bubble")
@export var bg_color: Color = Color(0.05, 0.2, 0.16, 0.6):
	set(value):
		bg_color = value
		if _background:
			_background.queue_redraw()
@export var border_color: Color = Color.WHITE:
	set(value):
		border_color = value
		if _background:
			_background.queue_redraw()
@export var border_width: float = 2.0:
	set(value):
		border_width = value
		if _background:
			_background.queue_redraw()
@export var corner_radius: float = 23.0:
	set(value):
		corner_radius = value
		if _background:
			_background.queue_redraw()
@export var pointer_size: Vector2 = Vector2(45, 30):
	set(value):
		pointer_size = value
		if _background:
			_background.queue_redraw()
@export var padding: Vector2 = Vector2(68, 26)

var _background: Control = null
var _original_bg_color: Color

func _ready() -> void:
	# 創建背景繪製節點
	_setup_background()

	# 設定 padding
	_setup_empty_style()

	# 保存原始背景色
	_original_bg_color = bg_color

	# 編輯器中延遲一幀後重繪，確保背景顯示
	if Engine.is_editor_hint():
		if get_tree():
			await get_tree().process_frame
			if _background:
				_background.queue_redraw()
		return

	pressed.connect(_on_pressed)
	pressed.connect(func():
		var tween = create_tween()
		var init_y = position.y
		tween.tween_property(self, 'position:y', init_y + size.y * 0.1, 0.01)
		tween.tween_property(self, 'position:y', init_y, 0.09)
	)


func _setup_background() -> void:
	# 創建背景節點
	_background = Control.new()
	_background.name = "SpeechBubbleBackground"
	_background.show_behind_parent = true
	_background.z_index = -1  # 確保背景在文字後面
	_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	# 連接繪製函數
	_background.draw.connect(_draw_background)

	# 當大小改變時重繪
	resized.connect(func(): _background.queue_redraw())


func _setup_empty_style() -> void:
	var empty_style = StyleBoxEmpty.new()
	empty_style.content_margin_left = padding.x
	empty_style.content_margin_right = padding.x
	empty_style.content_margin_top = padding.y
	empty_style.content_margin_bottom = padding.y
	add_theme_stylebox_override("normal", empty_style)
	add_theme_stylebox_override("hover", empty_style)
	add_theme_stylebox_override("pressed", empty_style)
	add_theme_stylebox_override("disabled", empty_style)
	add_theme_stylebox_override("focus", empty_style)


func _draw_background() -> void:
	var center_x = size.x / 2.0
	var pointer_top_y = size.y
	var pointer_bottom_y = size.y + pointer_size.y

	# 1. 繪製圓角矩形背景
	var rect = Rect2(Vector2.ZERO, size)
	_draw_rect_with_rounded_corners(rect, bg_color, corner_radius)

	# 2. 繪製尖端（三角形）
	var pointer_points = PackedVector2Array([
		Vector2(center_x - pointer_size.x / 2.0, pointer_top_y),
		Vector2(center_x + pointer_size.x / 2.0, pointer_top_y),
		Vector2(center_x, pointer_bottom_y)
	])
	_background.draw_colored_polygon(pointer_points, bg_color)

	# 3. 繪製圓角矩形邊框（底部留缺口給尖端）
	_draw_rect_border_with_gap(rect, border_color, corner_radius, border_width, center_x, pointer_size.x)

	# 4. 畫尖端的兩條斜邊
	_background.draw_line(pointer_points[0], pointer_points[2], border_color, border_width)
	_background.draw_line(pointer_points[1], pointer_points[2], border_color, border_width)


func _draw_rect_with_rounded_corners(rect: Rect2, color: Color, radius: float) -> void:
	var r = min(radius, rect.size.x / 2.0, rect.size.y / 2.0)

	# 中央矩形（橫向）
	_background.draw_rect(Rect2(rect.position.x + r, rect.position.y, rect.size.x - 2 * r, rect.size.y), color)
	# 左側矩形
	_background.draw_rect(Rect2(rect.position.x, rect.position.y + r, r, rect.size.y - 2 * r), color)
	# 右側矩形
	_background.draw_rect(Rect2(rect.position.x + rect.size.x - r, rect.position.y + r, r, rect.size.y - 2 * r), color)

	# 四個圓角（使用填充扇形）
	var segments = 16
	_draw_filled_arc(Vector2(rect.position.x + r, rect.position.y + r), r, PI, PI * 1.5, segments, color)
	_draw_filled_arc(Vector2(rect.position.x + rect.size.x - r, rect.position.y + r), r, PI * 1.5, PI * 2, segments, color)
	_draw_filled_arc(Vector2(rect.position.x + r, rect.position.y + rect.size.y - r), r, PI * 0.5, PI, segments, color)
	_draw_filled_arc(Vector2(rect.position.x + rect.size.x - r, rect.position.y + rect.size.y - r), r, 0, PI * 0.5, segments, color)


func _draw_filled_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, segments: int, color: Color) -> void:
	var points = PackedVector2Array()
	points.append(center)
	for i in range(segments + 1):
		var angle = start_angle + (end_angle - start_angle) * i / segments
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	_background.draw_colored_polygon(points, color)


func _draw_rect_border_with_gap(rect: Rect2, color: Color, radius: float, width: float, gap_center_x: float, gap_width: float) -> void:
	var r = min(radius, rect.size.x / 2.0, rect.size.y / 2.0)
	var bottom_y = rect.position.y + rect.size.y

	# 上邊
	_background.draw_line(Vector2(rect.position.x + r, rect.position.y), Vector2(rect.position.x + rect.size.x - r, rect.position.y), color, width)
	# 左邊
	_background.draw_line(Vector2(rect.position.x, rect.position.y + r), Vector2(rect.position.x, bottom_y - r), color, width)
	# 右邊
	_background.draw_line(Vector2(rect.position.x + rect.size.x, rect.position.y + r), Vector2(rect.position.x + rect.size.x, bottom_y - r), color, width)

	# 下邊（分成兩段，中間留缺口給尖端）
	var gap_left = gap_center_x - gap_width / 2.0
	var gap_right = gap_center_x + gap_width / 2.0
	_background.draw_line(Vector2(rect.position.x + r, bottom_y), Vector2(gap_left, bottom_y), color, width)
	_background.draw_line(Vector2(gap_right, bottom_y), Vector2(rect.position.x + rect.size.x - r, bottom_y), color, width)

	# 四個圓角弧線
	var segments = 16
	_background.draw_arc(Vector2(rect.position.x + r, rect.position.y + r), r, PI, PI * 1.5, segments, color, width)
	_background.draw_arc(Vector2(rect.position.x + rect.size.x - r, rect.position.y + r), r, PI * 1.5, PI * 2, segments, color, width)
	_background.draw_arc(Vector2(rect.position.x + r, bottom_y - r), r, PI * 0.5, PI, segments, color, width)
	_background.draw_arc(Vector2(rect.position.x + rect.size.x - r, bottom_y - r), r, 0, PI * 0.5, segments, color, width)


# 當按鈕被按下時調用
func _on_pressed():
	# 保存原始顏色並改變背景色
	_original_bg_color = bg_color
	bg_color = Color.CORNFLOWER_BLUE

	# 播放音效
	$sfx.play()

	# 回答後禁用按鈕
	disabled = true


# 從外部調用此函數以重置按鈕狀態
func reset():
	# 恢復預設外觀
	bg_color = _original_bg_color if _original_bg_color != Color() else Color(0.05, 0.2, 0.16, 0.6)
	# 重新啟用按鈕，為下一題做準備
	disabled = false
