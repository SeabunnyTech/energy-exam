extends BaseScreen

var map_name
var topic

func on_pre_enter(param):
	# 載入所有問題
	map_name = param['map_name']
	topic = param['topic']
	var score = GameState.get_topic_score(map_name, topic)['correct']
	%score.text = "你獲得了 " + str(score) + " 點積分"
	# print(questions)


func _ready() -> void:
	ui_to_fade = [$Panel, %MoreQuizButton, %MorePolicyButton]

	%MoreQuizButton.pressed.connect(_on_more_quiz_pressed)
	%MorePolicyButton.pressed.connect(_on_more_policy_pressed)
	reset()


func _on_more_quiz_pressed():
	leave_for_screen(map_name)


func _on_more_policy_pressed():
	leave_for_screen('policy', {'map_name':map_name, 'topic':topic})
