extends Control

## 後台管理主畫面
## 提供編輯 intro、topics、questions 的界面

signal goto_screen(new_screen_name: String, param: Dictionary)

enum EditorPanel {
	INTRO,
	TOPIC,
	QUESTION
}

@onready var nav_tree: Tree = $HSplitContainer/NavPanel/NavTree
@onready var editor_container: Control = $HSplitContainer/EditorPanel/EditorContainer
@onready var save_button: Button = $TopBar/SaveButton
@onready var return_button: Button = $TopBar/ReturnButton
@onready var status_label: Label = $TopBar/StatusLabel

var intro_editor: Control
var topic_editor: Control
var question_editor: Control

var current_editor: Control = null

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
	save_button.pressed.connect(_on_save_pressed)
	return_button.pressed.connect(_on_return_pressed)
	nav_tree.item_selected.connect(_on_nav_item_selected)

	_setup_nav_tree()
	_load_editors()

	# 預設顯示 intro 編輯器
	_show_editor(EditorPanel.INTRO)


func _setup_nav_tree():
	nav_tree.clear()
	nav_tree.hide_root = true
	var root = nav_tree.create_item()

	# 介紹頁
	var intro_item = nav_tree.create_item(root)
	intro_item.set_text(0, "介紹頁")
	intro_item.set_metadata(0, {"type": "intro"})

	# 主題設定
	var topics_item = nav_tree.create_item(root)
	topics_item.set_text(0, "主題設定")
	topics_item.set_selectable(0, false)

	for topic_key in TOPIC_NAMES.keys():
		var topic_item = nav_tree.create_item(topics_item)
		topic_item.set_text(0, TOPIC_NAMES[topic_key])
		topic_item.set_metadata(0, {"type": "topic", "topic": topic_key})

	# 題庫
	var questions_item = nav_tree.create_item(root)
	questions_item.set_text(0, "題庫")
	questions_item.set_selectable(0, false)

	for topic_key in TOPIC_NAMES.keys():
		var question_item = nav_tree.create_item(questions_item)
		question_item.set_text(0, TOPIC_NAMES[topic_key])
		question_item.set_metadata(0, {"type": "question", "topic": topic_key})


func _load_editors():
	# 載入編輯器場景
	var intro_scene = load("res://screens/admin/intro_editor.tscn")
	var topic_scene = load("res://screens/admin/topic_editor.tscn")
	var question_scene = load("res://screens/admin/question_editor.tscn")

	intro_editor = intro_scene.instantiate()
	topic_editor = topic_scene.instantiate()
	question_editor = question_scene.instantiate()

	editor_container.add_child(intro_editor)
	editor_container.add_child(topic_editor)
	editor_container.add_child(question_editor)

	intro_editor.visible = false
	topic_editor.visible = false
	question_editor.visible = false


func _show_editor(panel_type: EditorPanel, topic: String = ""):
	intro_editor.visible = false
	topic_editor.visible = false
	question_editor.visible = false

	match panel_type:
		EditorPanel.INTRO:
			intro_editor.visible = true
			intro_editor.load_content()
			current_editor = intro_editor
		EditorPanel.TOPIC:
			topic_editor.visible = true
			topic_editor.load_topic(topic)
			current_editor = topic_editor
		EditorPanel.QUESTION:
			question_editor.visible = true
			question_editor.load_questions(topic)
			current_editor = question_editor


func _on_nav_item_selected():
	var selected = nav_tree.get_selected()
	if selected == null:
		return

	var metadata = selected.get_metadata(0)
	if metadata == null:
		return

	var item_type = metadata.get("type", "")
	var topic = metadata.get("topic", "")

	match item_type:
		"intro":
			_show_editor(EditorPanel.INTRO)
		"topic":
			_show_editor(EditorPanel.TOPIC, topic)
		"question":
			_show_editor(EditorPanel.QUESTION, topic)


func _on_save_pressed():
	# 先讓當前編輯器儲存內容到 ContentLoader
	if current_editor and current_editor.has_method("save_to_content_loader"):
		current_editor.save_to_content_loader()

	# 儲存到檔案
	if ContentLoader.save_content():
		status_label.text = "已儲存"
		_flash_status()
	else:
		status_label.text = "儲存失敗"


func _flash_status():
	var tween = create_tween()
	tween.tween_property(status_label, "modulate:a", 1.0, 0.1)
	tween.tween_interval(2.0)
	tween.tween_property(status_label, "modulate:a", 0.0, 0.5)


func _on_return_pressed():
	# 詢問是否要儲存
	# 簡單起見，直接返回遊戲
	goto_screen.emit("welcome", {})


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			_on_return_pressed()
		elif event.keycode == KEY_S and event.ctrl_pressed:
			_on_save_pressed()
			get_viewport().set_input_as_handled()
