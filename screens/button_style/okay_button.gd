extends Button

class_name OkayButton



func _ready() -> void:
	pressed.connect($sfx.play)

	pressed.connect(func():
		var tween = create_tween()
		var init_y =	 position.y
		tween.tween_property(self, 'position:y', init_y + size.y * 0.1, 0.01)
		tween.tween_property(self, 'position:y', init_y, 0.09)
	)
