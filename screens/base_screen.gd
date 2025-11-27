extends Control

class_name BaseScreen

@export var map=null

signal request_map(map_name:String)
signal goto_screen(new_screen_name:String)

signal almost_finish_leaving

# 指向 super_scene 的指標
var _super_scene


func zoom_3d_camera_to(position_name:String):
	_super_scene.zoom_3d_camera_to(position_name)


func set_input_enable(enable):
	pass


func enter_animation():
	pass


func leave_animation():
	pass

func on_pre_enter():
	pass

func on_enter():
	pass

func on_pre_leave():
	pass

func on_leave():
	pass


func __enter__():
	request_map.emit("coast")
	on_pre_enter()
	await enter_animation()
	on_enter()
	set_input_enable(true)


func __leave__():
	set_input_enable(false)
	on_pre_leave()
	await leave_animation()
	on_leave()
	
	# 動畫完成後，從 super_scene 移除
	get_parent().remove_child(self)


func leave_for_screen(new_screen_name, time_to_next_screen_animation=0.4):
	# 先從 goto_screen 信號通知 SuperScene 說要切換了
	get_tree().create_timer(time_to_next_screen_animation).timeout.connect(almost_finish_leaving.emit)
	goto_screen.emit(new_screen_name)
