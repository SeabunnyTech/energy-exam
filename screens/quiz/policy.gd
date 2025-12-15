extends BaseScreen

var map_name
var topic

func on_pre_enter(param):
	# 載入所有問題
	map_name = param['map_name']
	topic = param['topic']


func _ready() -> void:
	ui_to_fade = $Control.get_children()

	%LeaveButton.pressed.connect(_on_leave_pressed)
	reset()


func _on_leave_pressed():
	leave_for_screen(map_name, {'map_name':map_name, 'topic':topic})
