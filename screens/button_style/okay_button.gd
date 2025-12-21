extends Button

class_name OkayButton



func _ready() -> void:
	pressed.connect($sfx.play)
	pressed.connect(func():
		var tween = create_tween()
		tween.tween_property(self, 'scale', Vector2.ONE * 0.9, 0.01)
		tween.tween_property(self, 'scale', Vector2.ONE, 0.09)
	)
