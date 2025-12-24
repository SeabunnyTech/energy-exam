extends BaseScreen

@onready var buttons = [$GroundSolarButton, $HydroPowerButton, $EnergyStorageButton]

var idle_timer: Timer


func _ready():
	
	ui_to_fade = buttons
	# Create and configure the timer for the idle animation
	idle_timer = Timer.new()
	idle_timer.wait_time = 5.0 # Every 5 seconds
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(idle_timer)

	$GroundSolarButton.pressed.connect(_on_solar_pressed)
	reset()


func set_input_enable(enable: bool):
	for button in buttons:
		button.disabled = not enable
		
	if enable:
		idle_timer.start()
		# Trigger once immediately
		_on_idle_timer_timeout()
	else:
		idle_timer.stop()
		# You might want to add a function to kill any active tweens here if necessary

# --- Idle Animation ---

func _on_idle_timer_timeout():
	var tween = create_tween().set_loops(1).set_parallel(false)
	
	var jump_height = 15.0
	var jump_duration = 0.2
	
	# Sequentially make each button "jump"
	for button in buttons:
		var initial_pos = button.position
		tween.chain().tween_property(button, "position", initial_pos - Vector2(0, jump_height), jump_duration)
		tween.chain().tween_property(button, "position", initial_pos, jump_duration)
		# Add a small delay before the next button jumps
		tween.chain().tween_interval(0.1)


func _on_solar_pressed():
	GlobalAudioPlayer.fade_out(1.0)
	move_camera_to_topic("solar")
	leave_for_screen("pre_quiz", {'map_name':'west', 'topic':'solar'})
	#request_camera_zoom_to("windpower")


func reset():
	for btn in buttons:
		btn.reset()
