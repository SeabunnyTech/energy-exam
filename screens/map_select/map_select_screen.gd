extends BaseScreen

@onready var guide_box = $GuideBox
@onready var map_cards_container = $HBoxContainer
@onready var animation_timer: Timer = Timer.new()

func reset():
	guide_box.modulate.a = 0.0
	for map_card in map_cards_container.get_children():
		map_card.modulate.a = 0.0
	set_input_enable(false)


func _ready():
	reset()
	for card in map_cards_container.get_children():
		var button = card.get_node("Outline/MarginContainer/Panel/Button")
		button.pressed.connect(_on_map_card_pressed.bind(card.title))
	
	animation_timer.wait_time = 5.0
	animation_timer.one_shot = false
	animation_timer.timeout.connect(_on_animation_timer_timeout)
	add_child(animation_timer)

var anim_duration = 0.7
var anim_latency = 0.2


func fade_all(target_opacity):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(guide_box, "modulate:a", target_opacity, anim_duration)

	var latency_index = 1
	for map_card in map_cards_container.get_children():
		tween.tween_property(map_card, "modulate:a", target_opacity, anim_duration)\
			 .set_delay(anim_latency*latency_index)
		latency_index += 1

	await tween.finished


func enter_animation():
	await fade_all(1.0)
	set_input_enable(true)
	_on_animation_timer_timeout() # Trigger animation once at the beginning


func leave_animation():
	set_input_enable(false)
	await fade_all(0.0)


func set_input_enable(enable):
	for card in map_cards_container.get_children():
		var button = card.get_node("Outline/MarginContainer/Panel/Button")
		button.disabled = not enable
	
	if enable:
		animation_timer.start()
	else:
		animation_timer.stop()


func _on_animation_timer_timeout():

	var delay_index = 0
	var delay_duration = 0.1

	for card in map_cards_container.get_children():
		card.play_jump_animation(delay_index * delay_duration)
		delay_index+= 1

func _on_map_card_pressed(map_name: String):
	print("Selected map: ", map_name)
	leave_for_screen("map")
