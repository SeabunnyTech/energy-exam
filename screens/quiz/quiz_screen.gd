extends BaseScreen

var questions = []
var ans_progress : int = 0

func on_pre_enter(param):
	# 載入所有問題
	var topic = param['topic']
	questions = GameState.load_questions(topic, 10)
	show_question(0)


func show_question(index:int):
	pass


func _ready() -> void:
	
	### 這個頁面的讀入和讀出不只有單純 fade in fade out
	### 每一次答題都會有一次 fade out
	var buttons = $Panel/ButtonContainer.get_children()
	ui_to_fade = [$Panel] + buttons
	for btn in buttons:
		btn.answered.connect(answered)

	reset()


func answered(is_correct):
	# 計分
	pass
