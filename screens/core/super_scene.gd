extends Node

@onready var map_container: Node3D = $MapContainer
@onready var screen_container: CanvasLayer = $ScreenContainer

var _current_screen: BaseScreen = null
var screen_instances = {}


# MODIFIED: 更新要載入的畫面列表
const SCREENS_TO_LOAD = {
	"welcome":"res://screens/opening/welcome.tscn",
	"energy_goal": "res://screens/opening/energy_goal.tscn",
	"intro": "res://screens/opening/intro.tscn",
	"select_map": "res://screens/select/map_select_screen.tscn",
	"map_changing": "res://screens/maps/map_changing_screen.tscn",
	"coast":"res://screens/maps/coast_screen.tscn",
	"west":"res://screens/maps/west_screen.tscn",
	"east":"res://screens/maps/east_screen.tscn",
	"pre_quiz": "res://screens/quiz/pre_quiz_screen.tscn",
	"quiz": "res://screens/quiz/quiz_screen.tscn",
	"result": "res://screens/ending/result_screen.tscn",
	"policy": "res://screens/ending/policy.tscn",
	"congrats":"res://screens/ending/congrats.tscn",
}

# 後台管理畫面（單獨載入，不在遊戲流程中）
var admin_screen: Control = null
var is_admin_mode: bool = false
var screen_before_admin: String = ""

func _ready() -> void:
	# 預載入所有畫面
	for screen_name in SCREENS_TO_LOAD:
		var screen_path = SCREENS_TO_LOAD[screen_name]
		var screen_scene = load(screen_path)
		var screen_instance = screen_scene.instantiate()
		screen_instance._super_scene = self
		screen_instances[screen_name] = screen_instance

	# 載入初始地圖
	#change_map("coast", 0.0)
	# 進入初始畫面
	goto_screen("welcome")


# MODIFIED: goto_screen 現在是狀態切換和依賴注入的核心
func goto_screen(screen_name: String, param=null) -> void:

	var container = 	$ScreenContainer

	# 只要有前一個頁面存在就應該播放離開並把它移除
	if _current_screen != null:
		_current_screen.goto_screen.disconnect(goto_screen)
		_current_screen.__leave__()
		await _current_screen.almost_finish_leaving

	# 加入新 Screen 並讓它進場
	var new_screen:BaseScreen = screen_instances[screen_name]
	container.add_child(new_screen)
	new_screen.__enter__(param)
	new_screen.goto_screen.connect(goto_screen)

	_current_screen = new_screen


# MODIFIED: 更換地圖時，需要確保當前畫面能拿到新的地圖引用
var current_map: Node3D = null
var map_instances = {'coast':null, 'west':null, 'east':null}
var map_paths = {
	'coast': "res://maps/Scene/map_coast.tscn",
	'west': "res://maps/Scene/map_west.tscn",
	'east': "res://maps/Scene/map_east.tscn",
}

func fade_curtain(opacity:float, duration: float=1.5):
	print("super scene fade curtain to ", duration)
	var tween = create_tween()
	tween.tween_property($Curtain, 'modulate:a', opacity, duration)


func change_map(map_name: String, duration: float=1.5, topic: String="overview") -> void:
	if current_map:
		map_container.remove_child(current_map)

	var map_scene = map_instances[map_name]
	if map_scene == null:
		map_scene = load(map_paths[map_name]).instantiate()
	current_map = map_scene

	map_container.add_child(current_map)
	$Curtain.modulate.a = 0.0
	current_map.zoom_to_topic(topic, duration)

	# 重置地圖上的設施狀態（如風機 boost_level）
	if current_map.has_method("reset"):
		current_map.reset()


func _input(event: InputEvent) -> void:
	# Tab 切換後台管理模式
	if event.is_action_pressed("admin_toggle"):
		_toggle_admin_mode()


func _toggle_admin_mode() -> void:
	if is_admin_mode:
		_exit_admin_mode()
	else:
		_enter_admin_mode()


func _enter_admin_mode() -> void:
	if is_admin_mode:
		return

	is_admin_mode = true

	# 隱藏當前遊戲畫面
	if _current_screen:
		_current_screen.visible = false

	# 載入後台管理畫面（如果還沒載入）
	if admin_screen == null:
		var admin_scene = load("res://screens/admin/admin_screen.tscn")
		admin_screen = admin_scene.instantiate()
		admin_screen.goto_screen.connect(_on_admin_goto_screen)

	screen_container.add_child(admin_screen)
	admin_screen.visible = true

	print("[SuperScene] 進入後台管理模式")


func _exit_admin_mode() -> void:
	if not is_admin_mode:
		return

	is_admin_mode = false

	# 移除後台管理畫面
	if admin_screen and admin_screen.get_parent():
		screen_container.remove_child(admin_screen)

	# 重新載入內容並顯示遊戲畫面
	ContentLoader.reload_content()

	if _current_screen:
		_current_screen.visible = true

	print("[SuperScene] 離開後台管理模式")


func _on_admin_goto_screen(_screen_name: String, _param: Dictionary) -> void:
	# 後台返回遊戲
	_exit_admin_mode()
