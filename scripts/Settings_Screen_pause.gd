extends Control

func _on_settings_back_button_pressed() -> void:
	$".".visible=false
	$"../Pause_Menu".visible=true
