extends BaseScreen

var map_name
var topic

var tex_path = {
	'wind':"res://screens/ending/Gemini_風場.jpg",
	'geothermal':"res://screens/ending/Gemini_地熱.jpg",
	'solar':"res://screens/ending/太陽能.jpg"
}


func on_pre_enter(param):
	# 載入所有問題
	print("Policy preenter")
	map_name = param['map_name']
	topic = param['topic']

	$Control/TextureRect.texture = load(tex_path[topic])
	$GuideLabel.text = GameState.load_policy(map_name, topic)
	self._super_scene.fade_curtain(1.0)


func _ready() -> void:
	ui_to_fade = [$GuideLabel, %LeaveButton, $Control]

	%LeaveButton.pressed.connect(_on_leave_pressed)
	reset()


func _on_leave_pressed():
	leave_for_screen('congrats')
