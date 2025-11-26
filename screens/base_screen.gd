extends Control

class_name BaseScreen

@export var map=null

signal request_map(map_name:String)
signal goto_screen(new_screen_name:String)


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


func leave_for_screen(new_screen_name):
	# 先從 goto_screen 信號通知 SuperScene 說要切換了
	goto_screen.emit(new_screen_name)
