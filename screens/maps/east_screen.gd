extends BaseMapScreen


func _setup_buttons():
	buttons = [$HydroPowerButton, $GeothermalButton, $RoofSolarButton, $EnergyStorageButton]
	ui_to_fade = buttons
	$GeothermalButton.pressed.connect(_on_geothermal_pressed)
	$HydroPowerButton.pressed.connect(_on_hydro_pressed)
	$RoofSolarButton.pressed.connect(_on_roof_solar_pressed)
	$EnergyStorageButton.pressed.connect(_on_energy_storage_pressed)


func _on_geothermal_pressed():
	go_to_quiz('east', 'geothermal')


func _on_hydro_pressed():
	go_to_quiz('east', 'hydro')


func _on_roof_solar_pressed():
	go_to_quiz('east', 'solar_roof')


func _on_energy_storage_pressed():
	go_to_quiz('east', 'energy_storage')
