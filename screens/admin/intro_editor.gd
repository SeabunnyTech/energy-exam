extends Control

## Intro 頁面編輯器
## 編輯遊戲開始前的三頁介紹文字

@onready var page_container: VBoxContainer = $VBoxContainer/ScrollContainer/PageContainer

var page_editors: Array[TextEdit] = []


func _ready():
	pass


func load_content():
	# 清除舊的編輯器
	for child in page_container.get_children():
		child.queue_free()
	page_editors.clear()

	# 載入頁面
	var pages = ContentLoader.get_intro_pages()

	for i in range(pages.size()):
		var page_panel = _create_page_editor(i + 1, pages[i])
		page_container.add_child(page_panel)


func _create_page_editor(page_num: int, content: String) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 225)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# 標題
	var label = Label.new()
	label.text = "第 %d 頁" % page_num
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	vbox.add_child(label)

	# 編輯區
	var text_edit = TextEdit.new()
	text_edit.text = content
	text_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.add_theme_font_size_override("font_size", 21)
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	vbox.add_child(text_edit)

	page_editors.append(text_edit)

	return panel


func save_to_content_loader():
	var pages: Array = []
	for editor in page_editors:
		pages.append(editor.text)
	ContentLoader.set_intro_pages(pages)
