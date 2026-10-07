extends BaseScreen

@onready var _loading_label: Label = $Label
@onready var _loading_timer: Timer = $Timer

var _current_dot_count: int = 0


func _ready() -> void:
	ui_to_fade = [$Curtain, $Label]
	if _loading_timer:
		_loading_timer.timeout.connect(_on_loading_timer_timeout)
		# 立即呼叫一次以初始化文字顯示，避免等待第一次計時器觸發
		# _on_loading_timer_timeout() 
	reset()

func on_enter(param):
	# param = {'map_name':map_name}
	var map_name : String = param["map_name"]
	self._super_scene.change_map(map_name, 0.0)
	await get_tree().create_timer(1.0).timeout
	leave_for_screen(map_name)


func set_input_enable(enable):
	_current_dot_count = 0
	_on_loading_timer_timeout()
	if enable:
		_loading_timer.start()
	else:
		_loading_timer.stop()


func _on_loading_timer_timeout() -> void:
	# 循環點點數量：0 -> 1 -> 2 -> 3 (0個點, 1個點, 2個點, 3個點)
	_current_dot_count = (_current_dot_count + 1) % 6
	var dots = ".".repeat(_current_dot_count)\
			 + " ".repeat(6 - _current_dot_count)

	if _loading_label:
		_loading_label.text = Lang.t("loading") + dots
