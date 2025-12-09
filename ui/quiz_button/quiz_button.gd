extends Button
class_name QuizButton

signal answered(is_correct:bool)

@export var is_correc_answer: bool = false

func _ready() -> void:
	pressed.connect(answer_pressed)


func answer_pressed():
	var sfx = $wrong_sfx
	if is_correc_answer:
		sfx = $success_sfx
	sfx.play()
	answered.emit(is_correc_answer)
