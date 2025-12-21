extends BaseScreen

var map_name
var topic
var index = 0

var questions = []

@export var idle_music: AudioStream

func on_pre_enter(param):
	# 載入所有問題
	map_name = param['map_name']
	topic = param['topic']
	questions = QuestionReader.load_questions(topic)
	GlobalAudioPlayer.play_music(idle_music, 1.)
	# print(questions)
	load_question()

### 問題

@onready var q_index = %Q_index
@onready var q_title = %Q_title
@onready var q_score = %Q_score
@onready var q_content = %Q_content

### 答案選項
@onready var four_ans = $Panel/FourAnswerContainer
@onready var two_ans = $Panel/TwoAnswerContainer



func reset():
	super.reset()
	index = 0
	reset_buttons()


func reset_buttons():
	for ans in [four_ans, two_ans]:
		for btn in ans.get_children():
			btn.reset()


var answer_container
func load_question():
	var question = questions[index]

	### 設定問題區塊的文字
	q_index.text = "Q" + str(index+1) + ":"
	q_title.text = question['標題']
	
	var records = GameState.get_topic_score(map_name, topic)
	q_score.text = str(records['correct']) + '/' + str(records['answered']) + "/" + str(questions.size())
	q_content.text = question['內容']

	### 設定選項區塊的文字
	var ans_options = question['選項']

	## 切換四個答案或兩個答案
	var use_two_ans:bool = ans_options.size() == 2

	two_ans.visible = use_two_ans
	four_ans.visible = not use_two_ans
	answer_container = two_ans if use_two_ans else four_ans

	## ui_to_fade
	ui_to_fade = [$Panel, answer_container]

	## 填入選項的文字
	for ans_index in range(ans_options.size()):
		var btn : QuizButton = answer_container.get_node("Button" + str(ans_index+1))
		btn.text = ans_options[ans_index]
		btn.is_correct_answer = question['答案'] == ans_index + 1


func _ready() -> void:
	### 這個頁面的讀入和讀出不只有單純 fade in fade out
	### 每一次答題都會有一次 fade out
	for ans in [two_ans, four_ans]:
		for btn in ans.get_children():
			btn.answered.connect(answered)

	reset()


func load_next_question():
	### 淡出現在的問題
	await fade_all(0.0, 0.3, 0.1)
	
	reset_buttons()

	### 載入新問題
	index = index + 1
	load_question()

	### 淡入
	fade_all(1.0, 0.3, 0.1)


func answered(is_correct):
	# 計分
	
	GameState.push_score(map_name, topic, is_correct)
	if is_correct:
		self._super_scene.current_map.boost_facility(topic)

	var new_index = index + 1

	################ 答完一題直接跳到結局的暫時邏輯 ##################
	if  new_index == 1:
		leave_for_screen('result', {'map_name':map_name, 'topic':topic})
		return

	### 以下才是原有的邏輯
	if new_index == questions.size():
		leave_for_screen('result', {'map_name':map_name, 'topic':topic})
	else:
		load_next_question()


func on_leave():
	reset()
