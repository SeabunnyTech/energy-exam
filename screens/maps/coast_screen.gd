extends BaseMapScreen


func _setup_buttons():
	buttons = [$WindPowerButton, $GroundSolarButton, $RoofSolarButton, $EnergyStorageButton]
	ui_to_fade = buttons
	$WindPowerButton.pressed.connect(_on_windpower_pressed)
	$GroundSolarButton.pressed.connect(_on_ground_solar_pressed)
	$RoofSolarButton.pressed.connect(_on_roof_solar_pressed)
	$EnergyStorageButton.pressed.connect(_on_energy_storage_pressed)


func _on_windpower_pressed():
	go_to_quiz('coast', 'wind')


func _on_ground_solar_pressed():
	go_to_quiz('coast', 'solar_ground')


func _on_roof_solar_pressed():
	go_to_quiz('coast', 'solar_roof')


func _on_energy_storage_pressed():
	go_to_quiz('coast', 'energy_storage')
