extends Control

func _ready() -> void:
	var sfx_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	var music_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	$GridContainer/SFXSlider.value = db_to_linear(sfx_db)
	$GridContainer/MusicSlider.value = db_to_linear(music_db)

func _on_settings_back_button_pressed() -> void:
	visible = false


func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	$SFXPlayer.play()
	if value_changed:
		var sfx_db = linear_to_db($GridContainer/SFXSlider.value)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_db)


func _on_music_slider_value_changed(value: float) -> void:
	var music_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)
