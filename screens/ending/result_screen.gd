extends BaseScreen

var map_name
var topic

func on_pre_enter(param):
	# 載入所有問題
	map_name = param['map_name']
	topic = param['topic']
	var score = GameState.get_topic_score(map_name, topic)['correct']
	%Q_index.text = Lang.t("result_title")
	%score.text = Lang.t("result_score") % score
	%total_score.text = Lang.t("result_total_score") % GameState.total_score
	%MorePolicyButton.text = Lang.t("more_policy")
	# print(questions)


func _ready() -> void:
	ui_to_fade = [$Panel, %MorePolicyButton]

	#%MoreQuizButton.pressed.connect(_on_more_quiz_pressed)
	%MorePolicyButton.pressed.connect(_on_more_policy_pressed)
	reset()


func _on_more_quiz_pressed():
	leave_for_screen(map_name)


func _on_more_policy_pressed():
	leave_for_screen('policy', {'map_name':map_name, 'topic':topic})
