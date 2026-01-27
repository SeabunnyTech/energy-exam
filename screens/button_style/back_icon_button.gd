extends Button

class_name BackIconButton


func _ready() -> void:
	pressed.connect($sfx.play)

	pressed.connect(func():
		var tween = create_tween()
		var init_x = position.x
		tween.tween_property(self, 'position:x', init_x - size.x * 0.1, 0.01)
		tween.tween_property(self, 'position:x', init_x, 0.09)
	)
