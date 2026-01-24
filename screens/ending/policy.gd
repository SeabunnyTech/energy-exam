extends BaseScreen

var map_name
var topic

var tex_path = {
	'wind': "res://screens/ending/Gemini_風場.jpg",
	'geothermal': "res://screens/ending/Gemini_地熱.jpg",
	'solar': "res://screens/ending/太陽能.jpg",
	# 以下為新主題，尚未有專屬圖片
	'solar_ground': "res://screens/ending/太陽能.jpg",
	'solar_roof': "res://screens/ending/太陽能.jpg",
	'hydro': null,  # 水力發電圖片待補充
	'energy_storage': null,  # 儲能圖片待補充
}

const MISSING_TEXTURE_MSG = "[缺少圖片] 請為主題 '%s' 添加圖片到 tex_path"
const MISSING_POLICY_MSG = "[缺少政策文字] 請在 GameState.load_policy() 中為 map='%s', topic='%s' 添加內容"


func on_pre_enter(param):
	print("Policy preenter")
	map_name = param['map_name']
	topic = param['topic']

	# 容錯：載入圖片
	if tex_path.has(topic) and tex_path[topic] != null:
		var tex = load(tex_path[topic])
		if tex:
			$Control/TextureRect.texture = tex
		else:
			push_warning(MISSING_TEXTURE_MSG % topic)
	else:
		push_warning(MISSING_TEXTURE_MSG % topic)
		$Control/TextureRect.texture = null

	# 容錯：載入政策文字
	var policy_text = _safe_load_policy(map_name, topic)
	$GuideLabel.text = policy_text
	self._super_scene.fade_curtain(1.0)


func _ready() -> void:
	ui_to_fade = [$GuideLabel, %LeaveButton, $Control]

	%LeaveButton.pressed.connect(_on_leave_pressed)
	reset()


func _on_leave_pressed():
	leave_for_screen('congrats')


func _safe_load_policy(p_map_name: String, p_topic: String) -> String:
	var policy = GameState.load_policy(p_map_name, p_topic)
	if policy == null or policy.is_empty():
		push_warning(MISSING_POLICY_MSG % [p_map_name, p_topic])
		return MISSING_POLICY_MSG % [p_map_name, p_topic]
	if policy.begins_with("（") and policy.ends_with("）"):
		# 這是佔位符文字，顯示警告
		push_warning("政策文字為佔位符: %s / %s" % [p_map_name, p_topic])
	return policy
