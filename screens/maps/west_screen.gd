extends BaseMapScreen


func _setup_buttons():
	buttons = [$GroundSolarButton, $HydroPowerButton, $EnergyStorageButton]
	button_topics = {
		$GroundSolarButton: {'map_name': 'west', 'topic': 'solar_ground'},
		$HydroPowerButton: {'map_name': 'west', 'topic': 'hydro', 'text_key': 'facility_hydro_west'},
		$EnergyStorageButton: {'map_name': 'west', 'topic': 'energy_storage'},
	}
	ui_to_fade = buttons + [%BackButton]
	$GroundSolarButton.pressed.connect(_on_solar_pressed)
	$HydroPowerButton.pressed.connect(_on_hydro_pressed)
	$EnergyStorageButton.pressed.connect(_on_energy_storage_pressed)
	%BackButton.pressed.connect(_on_back_pressed)


func _on_solar_pressed():
	go_to_quiz('west', 'solar_ground')


func _on_hydro_pressed():
	go_to_quiz('west', 'hydro')


func _on_energy_storage_pressed():
	go_to_quiz('west', 'energy_storage')


func _on_back_pressed():
	leave_for_screen('select_map')
