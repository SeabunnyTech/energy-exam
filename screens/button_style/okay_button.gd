extends Button

class_name OkayButton

func _ready() -> void:
	pressed.connect($sfx.play)
