extends Control

<<<<<<< HEAD
func pause() -> void:
	visible = true
	get_tree().paused = true

func resume() -> void:
	visible = false
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		resume()
		get_viewport().set_input_as_handled()

func _on_resume_button_pressed() -> void:
	resume()

func _on_settings_button_pressed() -> void:
	$SettingsScreen.visible = true

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
=======
var is_paused := false

func _ready():
	visible = false

func toggle_pause():
	is_paused = !is_paused
	visible = is_paused
	get_tree().paused = is_paused

func resume():
	is_paused = false
	visible = false
	get_tree().paused = false

func pause():
	is_paused = true
	visible = true
	get_tree().paused = true

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func _on_resume_button_pressed():
	resume()

func _on_settings_button_pressed():
	$Pause_Menu.visible=false
	$Settings_Screen.visible=true

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
>>>>>>> 45327c7 (update)
