extends BaseScreen

@onready var map_cards_container = $HBoxContainer
@onready var animation_timer: Timer = $Timer


@export var idle_music: AudioStream

func on_pre_enter(_param):
	GlobalAudioPlayer.play_music(idle_music, 1.)


func _ready():
	for card in map_cards_container.get_children():
		card.button_pressed.connect(_on_map_card_pressed.bind(card.map_name))

	animation_timer.timeout.connect(_on_animation_timer_timeout)
	ui_to_fade = [$Label] +  map_cards_container.get_children()
	reset()



func set_input_enable(enable):
	for card in map_cards_container.get_children():
		var button = card.get_node("Outline/MarginContainer/Panel/Button")
		button.disabled = not enable
	
	if enable:
		_on_animation_timer_timeout()
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
	leave_for_screen("map_changing", {'map_name':map_name})
