extends BaseScreen

# Assuming the buttons are in a container named "ButtonContainer"
@onready var button_container = $ButtonContainer

@onready var buttons = [$WindPowerButton, $GroundSolarButton, $RoofSolarButton, $EnergyStorageButton]

var idle_timer: Timer

func _ready():
	# Create and configure the timer for the idle animation
	idle_timer = Timer.new()
	idle_timer.wait_time = 5.0 # Every 5 seconds
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(idle_timer)

	$WindPowerButton.pressed.connect(_on_windpower_pressed)
	reset()

func reset():
	# Set initial state (all buttons invisible and disabled)
	for button in buttons:
		button.modulate.a = 0.0
		#button.disabled = true

# --- Screen Lifecycle Functions ---


func fade_all(target_opacity):
	var tween = create_tween().set_parallel(true)
	#tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	# Sequentially fade out each button (in parallel with delays for a cascade effect)
	var delay = 0.0
	for button in buttons:
		tween.tween_property(button, "modulate:a", target_opacity, 0.3).set_delay(delay)
		delay += 0.15
	await tween.finished


func enter_animation():
	await fade_all(1.0)


func leave_animation():
	await fade_all(0.0)



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


func _on_windpower_pressed():
	leave_for_screen("quiz")
	#request_camera_zoom_to("windpower")
