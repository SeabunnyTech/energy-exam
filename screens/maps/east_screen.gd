extends BaseMapScreen


func _setup_buttons():
	buttons = [$HydroPowerButton, $GeothermalButton, $RoofSolarButton, $EnergyStorageButton]
	button_topics = {
		$HydroPowerButton: {'map_name': 'east', 'topic': 'hydro'},
		$GeothermalButton: {'map_name': 'east', 'topic': 'geothermal'},
		$RoofSolarButton: {'map_name': 'east', 'topic': 'solar_roof'},
		$EnergyStorageButton: {'map_name': 'east', 'topic': 'energy_storage'},
	}
	ui_to_fade = buttons + [%BackButton]
	$GeothermalButton.pressed.connect(_on_geothermal_pressed)
	$HydroPowerButton.pressed.connect(_on_hydro_pressed)
	$RoofSolarButton.pressed.connect(_on_roof_solar_pressed)
	$EnergyStorageButton.pressed.connect(_on_energy_storage_pressed)
	%BackButton.pressed.connect(_on_back_pressed)


func _on_geothermal_pressed():
	go_to_quiz('east', 'geothermal')


func _on_hydro_pressed():
	go_to_quiz('east', 'hydro')


func _on_roof_solar_pressed():
	go_to_quiz('east', 'solar_roof')


func _on_energy_storage_pressed():
	go_to_quiz('east', 'energy_storage')


func _on_back_pressed():
	leave_for_screen('select_map')
