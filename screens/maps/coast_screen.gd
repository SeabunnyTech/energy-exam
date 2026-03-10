extends BaseMapScreen


func _setup_buttons():
	buttons = [$WindPowerButton, $GroundSolarButton, $RoofSolarButton, $EnergyStorageButton]
	button_topics = {
		$WindPowerButton: {'map_name': 'coast', 'topic': 'wind'},
		$GroundSolarButton: {'map_name': 'coast', 'topic': 'solar_ground'},
		$RoofSolarButton: {'map_name': 'coast', 'topic': 'solar_roof'},
		$EnergyStorageButton: {'map_name': 'coast', 'topic': 'energy_storage'},
	}
	ui_to_fade = buttons + [%BackButton]
	$WindPowerButton.pressed.connect(_on_windpower_pressed)
	$GroundSolarButton.pressed.connect(_on_ground_solar_pressed)
	$RoofSolarButton.pressed.connect(_on_roof_solar_pressed)
	$EnergyStorageButton.pressed.connect(_on_energy_storage_pressed)
	%BackButton.pressed.connect(_on_back_pressed)


func _on_windpower_pressed():
	go_to_quiz('coast', 'wind')


func _on_ground_solar_pressed():
	go_to_quiz('coast', 'solar_ground')


func _on_roof_solar_pressed():
	go_to_quiz('coast', 'solar_roof')


func _on_energy_storage_pressed():
	go_to_quiz('coast', 'energy_storage')


func _on_back_pressed():
	leave_for_screen('select_map')
