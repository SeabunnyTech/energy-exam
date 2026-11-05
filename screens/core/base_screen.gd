extends Control

class_name BaseScreen

signal goto_screen(new_screen_name:String, param:Dictionary)

signal almost_finish_leaving

# 指向 super_scene 的指標
var _super_scene


func zoom_3d_camera_to(position_name:String):
	_super_scene.zoom_3d_camera_to(position_name)


func set_input_enable(_enable):
	pass

var ui_to_fade = []

func reset():
	# 確保已經 ready 才去繼續
	set_input_enable(false)
	for ui in ui_to_fade:
		ui.modulate.a = 0.0


func fade_all(target_opacity, duration=0.7, latency=0.2):
	var tween = create_tween().set_parallel(true)
	var delay = 0.0
	for ui in ui_to_fade:
		tween.tween_property(ui, "modulate:a", target_opacity, duration).set_delay(delay)
		delay += latency
	await tween.finished


func enter_animation():
	await fade_all(1.0)
	await _wait_for_narration()
	set_input_enable(true)
	start_beating_anim()


## 語音口白播放期間，這些按鈕會變淡（不能按由 enter_animation 等語音播完才開放）
var narration_locked_ui = []

## 子類在 on_pre_enter 呼叫；沒有對應語音時（例如中文模式）不影響進場流程
func start_narration(key: String):
	Narration.speak(key)
	_dim_narration_locked_ui(Narration.playing)
	if Narration.playing:
		set_input_enable(false)


func _wait_for_narration():
	if Narration.playing:
		await Narration.ended
	_dim_narration_locked_ui(false)


func _dim_narration_locked_ui(dim: bool):
	for ui in narration_locked_ui:
		ui.self_modulate.a = 0.35 if dim else 1.0


func leave_animation():
	set_input_enable(false)
	await fade_all(0.0)


func start_beating_anim():
	pass


func on_pre_enter(_param):
	pass

func on_enter(_param):
	pass

func on_pre_leave():
	pass

func on_leave():
	pass


func move_camera_to_topic(topic:String):
	self._super_scene.current_map.zoom_to_topic(topic)


func __enter__(param=null):
	await on_pre_enter(param)
	await enter_animation()
	on_enter(param)
	set_input_enable(true)


func __leave__():
	Narration.stop_speaking()
	set_input_enable(false)
	on_pre_leave()
	await leave_animation()
	on_leave()
	
	# 動畫完成後，從 super_scene 移除
	get_parent().remove_child(self)


func leave_for_screen(new_screen_name, param={}):
	var time_to_next_screen_animation : float = 0.4
	if 'time_to_next_screen_animation' in param:
		time_to_next_screen_animation = param['time_to_next_screen_animation']

	# 先從 goto_screen 信號通知 SuperScene 說要切換了
	get_tree().create_timer(time_to_next_screen_animation).timeout.connect(almost_finish_leaving.emit)
	goto_screen.emit(new_screen_name, param)
