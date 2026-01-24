extends BaseMapScreen


func _setup_buttons():
	buttons = [$GroundSolarButton, $HydroPowerButton, $EnergyStorageButton]
	ui_to_fade = buttons
	$GroundSolarButton.pressed.connect(_on_solar_pressed)
	$HydroPowerButton.pressed.connect(_on_hydro_pressed)
	$EnergyStorageButton.pressed.connect(_on_energy_storage_pressed)


func _on_solar_pressed():
	go_to_quiz('west', 'solar')


func _on_hydro_pressed():
	go_to_quiz('west', 'hydro')


func _on_energy_storage_pressed():
	go_to_quiz('west', 'energy_storage')
