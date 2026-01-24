extends BaseScreen

var map_name
var topic


func on_enter(_param):
	pass
	#$sfx.play()


func _ready() -> void:
	ui_to_fade = [$GuideLabel, $GuideLabel2, %LeaveButton, $TextureRect, $QRCodeRect, $QRCodeLabel]

	%LeaveButton.pressed.connect(_on_leave_pressed)
	reset()


func _on_leave_pressed():
	leave_for_screen('welcome')
	GlobalAudioPlayer.fade_out(1.0)
