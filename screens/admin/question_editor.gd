extends Control

## 題庫編輯器
## 編輯問答題目，支援新增、刪除、修改

@onready var title_label: Label = $VBoxContainer/TopBar/TitleLabel
@onready var add_button: Button = $VBoxContainer/TopBar/AddButton
@onready var question_list: ItemList = $VBoxContainer/HSplitContainer/ListPanel/QuestionList
@onready var detail_panel: Control = $VBoxContainer/HSplitContainer/DetailPanel
@onready var question_title_edit: LineEdit = $VBoxContainer/HSplitContainer/DetailPanel/ScrollContainer/VBoxContainer/TitleSection/QuestionTitleEdit
@onready var content_edit: TextEdit = $VBoxContainer/HSplitContainer/DetailPanel/ScrollContainer/VBoxContainer/ContentSection/ContentEdit
@onready var options_container: VBoxContainer = $VBoxContainer/HSplitContainer/DetailPanel/ScrollContainer/VBoxContainer/OptionsSection/OptionsContainer
@onready var add_option_button: Button = $VBoxContainer/HSplitContainer/DetailPanel/ScrollContainer/VBoxContainer/OptionsSection/AddOptionButton
@onready var delete_button: Button = $VBoxContainer/HSplitContainer/DetailPanel/ScrollContainer/VBoxContainer/ButtonSection/DeleteButton

var current_topic: String = ""
var current_questions: Array = []
var current_index: int = -1
var option_editors: Array = []  # Array of {container, edit, radio}

# 主題中文名稱對照
const TOPIC_NAMES = {
	"wind": "離岸風電",
	"solar": "太陽光電",
	"solar_ground": "地面太陽能",
	"solar_roof": "屋頂太陽能",
	"geothermal": "地熱能",
	"hydro": "水力發電",
	"energy_storage": "儲能系統"
}


func _ready():
	add_button.pressed.connect(_on_add_question)
	question_list.item_selected.connect(_on_question_selected)
	add_option_button.pressed.connect(_on_add_option)
	delete_button.pressed.connect(_on_delete_question)

	detail_panel.visible = false


func load_questions(topic: String):
	current_topic = topic
	current_index = -1
	var topic_name = TOPIC_NAMES.get(topic, topic)
	title_label.text = "%s 題庫" % topic_name

	# 載入題目
	current_questions = ContentLoader.get_questions(topic).duplicate(true)

	_refresh_question_list()
	detail_panel.visible = false


func _refresh_question_list():
	question_list.clear()

	for i in range(current_questions.size()):
		var q = current_questions[i]
		var title = q.get("title", "未命名題目")
		question_list.add_item("%d. %s" % [i + 1, title])


func _on_question_selected(index: int):
	# 先儲存當前編輯的題目
	if current_index >= 0:
		_save_current_question()

	current_index = index
	_load_question_detail(index)
	detail_panel.visible = true


func _load_question_detail(index: int):
	if index < 0 or index >= current_questions.size():
		return

	var q = current_questions[index]

	question_title_edit.text = q.get("title", "")
	content_edit.text = q.get("content", "")

	# 清除舊的選項編輯器
	_clear_option_editors()

	# 建立選項編輯器
	var options = q.get("options", [])
	var answer = q.get("answer", 1)

	for i in range(options.size()):
		_add_option_editor(options[i], i + 1 == answer)


func _clear_option_editors():
	for editor_data in option_editors:
		editor_data["container"].queue_free()
	option_editors.clear()


func _add_option_editor(text: String = "", is_correct: bool = false):
	var option_num = option_editors.size() + 1

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	# 選項編號 + 正確答案選擇
	var radio = CheckBox.new()
	radio.text = "%d." % option_num
	radio.button_pressed = is_correct
	radio.add_theme_font_size_override("font_size", 20)
	radio.toggled.connect(_on_answer_toggled.bind(option_num - 1))
	hbox.add_child(radio)

	# 選項文字
	var edit = LineEdit.new()
	edit.text = text
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.custom_minimum_size = Vector2(0, 38)
	edit.add_theme_font_size_override("font_size", 20)
	edit.placeholder_text = "選項內容..."
	hbox.add_child(edit)

	# 刪除按鈕
	var del_btn = Button.new()
	del_btn.text = "X"
	del_btn.custom_minimum_size = Vector2(38, 38)
	del_btn.pressed.connect(_on_delete_option.bind(option_num - 1))
	hbox.add_child(del_btn)

	options_container.add_child(hbox)
	option_editors.append({"container": hbox, "edit": edit, "radio": radio})


func _on_answer_toggled(pressed: bool, option_index: int):
	if pressed:
		# 取消其他選項的選取
		for i in range(option_editors.size()):
			if i != option_index:
				option_editors[i]["radio"].button_pressed = false


func _on_add_option():
	if option_editors.size() >= 5:
		return  # 最多5個選項
	_add_option_editor("", false)


func _on_delete_option(index: int):
	if option_editors.size() <= 2:
		return  # 最少2個選項

	var was_correct = option_editors[index]["radio"].button_pressed
	option_editors[index]["container"].queue_free()
	option_editors.remove_at(index)

	# 更新選項編號
	for i in range(option_editors.size()):
		option_editors[i]["radio"].text = "%d." % (i + 1)

	# 如果刪除的是正確答案，設第一個為正確
	if was_correct and option_editors.size() > 0:
		option_editors[0]["radio"].button_pressed = true


func _save_current_question():
	if current_index < 0 or current_index >= current_questions.size():
		return

	var q = current_questions[current_index]
	q["title"] = question_title_edit.text
	q["content"] = content_edit.text

	# 收集選項
	var options: Array = []
	var answer = 1
	for i in range(option_editors.size()):
		options.append(option_editors[i]["edit"].text)
		if option_editors[i]["radio"].button_pressed:
			answer = i + 1

	q["options"] = options
	q["answer"] = answer


func _on_add_question():
	var new_question = {
		"id": current_questions.size() + 1,
		"title": "新題目",
		"content": "請輸入題目內容",
		"answer": 1,
		"options": ["選項A", "選項B"]
	}
	current_questions.append(new_question)
	_refresh_question_list()

	# 選取新題目
	question_list.select(current_questions.size() - 1)
	_on_question_selected(current_questions.size() - 1)


func _on_delete_question():
	if current_index < 0 or current_index >= current_questions.size():
		return

	current_questions.remove_at(current_index)
	_refresh_question_list()

	current_index = -1
	detail_panel.visible = false


func save_to_content_loader():
	# 儲存當前編輯的題目
	if current_index >= 0:
		_save_current_question()

	ContentLoader.set_questions(current_topic, current_questions)
