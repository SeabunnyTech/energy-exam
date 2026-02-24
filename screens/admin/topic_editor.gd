extends Control

## 主題編輯器
## 編輯主題的標題、引導文字、政策說明

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var title_edit: LineEdit = $VBoxContainer/TitleSection/TitleEdit
@onready var guide_edit: TextEdit = $VBoxContainer/GuideSection/GuideEdit
@onready var policy_edit: TextEdit = $VBoxContainer/PolicySection/PolicyEdit

var current_topic: String = ""

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
	pass


func load_topic(topic: String):
	current_topic = topic
	var topic_name = TOPIC_NAMES.get(topic, topic)
	title_label.text = "編輯主題: %s" % topic_name

	var data = ContentLoader.get_topic_data(topic)
	title_edit.text = data.get("title", "")
	guide_edit.text = data.get("guide", "")
	policy_edit.text = data.get("policy", "")


func save_to_content_loader():
	if current_topic == "":
		return

	ContentLoader.set_topic_title(current_topic, title_edit.text)
	ContentLoader.set_topic_guide(current_topic, guide_edit.text)
	ContentLoader.set_topic_policy(current_topic, policy_edit.text)
