extends BaseScreen

var map_name
var topic

const MISSING_POLICY_MSG = "[缺少政策文字] 請在 GameState.load_policy() 中為 map='%s', topic='%s' 添加內容"


func on_pre_enter(param):
	print("Policy preenter")
	map_name = param['map_name']
	topic = param['topic']

	# 容錯：載入政策文字
	var policy_text = _safe_load_policy(map_name, topic)
	$GuideLabel.text = policy_text
	self._super_scene.fade_curtain(1.0)


func _ready() -> void:
	ui_to_fade = [$GuideLabel, %BackToMapButton, %LeaveButton]

	%LeaveButton.pressed.connect(_on_leave_pressed)
	%BackToMapButton.pressed.connect(_on_back_to_map_pressed)
	reset()


func _on_leave_pressed():
	leave_for_screen('congrats')


func _on_back_to_map_pressed():
	leave_for_screen('map_changing', {'map_name': map_name})


func _safe_load_policy(p_map_name: String, p_topic: String) -> String:
	var policy = GameState.load_policy(p_map_name, p_topic)
	if policy == null or policy.is_empty():
		push_warning(MISSING_POLICY_MSG % [p_map_name, p_topic])
		return MISSING_POLICY_MSG % [p_map_name, p_topic]
	if policy.begins_with("（") and policy.ends_with("）"):
		# 這是佔位符文字，顯示警告
		push_warning("政策文字為佔位符: %s / %s" % [p_map_name, p_topic])
	return policy
