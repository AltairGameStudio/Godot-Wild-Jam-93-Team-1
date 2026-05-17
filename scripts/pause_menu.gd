extends Control

func pause() -> void:
	visible = true
	get_tree().paused = true

func resume() -> void:
	visible = false
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if $/root/World/HUD/ControlsScreen.visible:
		return # Se o tutorial já estiver aberto, não processa o input de pausa
	
	if event.is_action_pressed("pause"):
		resume()
		get_viewport().set_input_as_handled()

func _on_resume_button_pressed() -> void:
	resume()

func _on_settings_button_pressed() -> void:
	$SettingsScreen.visible = true

func _on_main_menu_button_pressed() -> void:
	# Despausa o jogo antes de voltar pro menu
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
