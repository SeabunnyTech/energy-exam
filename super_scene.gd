extends Node

@onready var map_container: Node3D = $MapContainer
@onready var screen_container: CanvasLayer = $ScreenContainer

var _current_screen: BaseScreen = null
var current_map: Node3D = null
var screen_instances = {}

# MODIFIED: 更新要載入的畫面列表
const SCREENS_TO_LOAD = {
	#"MapBrowsing": "res://screens/map_browsing_screen.tscn",
	#"Quiz": "res://screens/quiz_screen.tscn",
	"login": "res://screens/login_screen.tscn", # Login 畫面可以暫時移除或保留
	"select_map": "res://screens/map_select/map_select_screen.tscn"
}

func _ready() -> void:
	# 預載入所有畫面
	for screen_name in SCREENS_TO_LOAD:
		var screen_path = SCREENS_TO_LOAD[screen_name]
		var screen_scene = load(screen_path)
		var screen_instance = screen_scene.instantiate()
		screen_instances[screen_name] = screen_instance
		
	# 載入初始地圖
	_on_map_change_requested("res://maps/Scene/map01/map_coast_model.tscn") 
	# 進入初始畫面
	goto_screen("login")


# MODIFIED: goto_screen 現在是狀態切換和依賴注入的核心
func goto_screen(screen_name: String) -> void:

	var container = 	$ScreenContainer

	# 只要有前一個頁面存在就應該播放離開並把它移除
	if _current_screen != null:
		_current_screen.goto_screen.disconnect(goto_screen)
		await _current_screen.__leave__()
		container.remove_child(_current_screen)

	var new_screen:BaseScreen = screen_instances[screen_name]

	# 加入新 Screen 並讓它進場
	container.add_child(new_screen)
	await new_screen.__enter__()
	new_screen.goto_screen.connect(goto_screen)
	_current_screen = new_screen



# MODIFIED: 更換地圖時，需要確保當前畫面能拿到新的地圖引用
func _on_map_change_requested(map_path: String) -> void:
	if current_map:
		current_map.queue_free()
		current_map = null

	var map_scene = load(map_path)
	if map_scene:
		current_map = map_scene.instantiate()
		map_container.add_child(current_map)
		
		# 如果在更換地圖時已經有活動的畫面，則需要重新觸發它的 enter 方法
		# 以便它能更新內部的地圖引用並重新連接信號
		if _current_screen:
			_current_screen.enter()
	else:
		push_error("Failed to load map: %s" % map_path)

# 所有與 quiz progress 相關的函式都已移除，SuperScene 不再關心狀態的內部邏輯
