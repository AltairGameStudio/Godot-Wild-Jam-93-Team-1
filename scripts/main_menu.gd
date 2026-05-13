extends Control

var game_scene = load("res://scenes/world.tscn")

func _on_play_button_pressed() -> void:
	GameManager.start_game()
	var error = get_tree().change_scene_to_packed(game_scene)
	if error != OK:
		print("Erro ao carregar a cena do jogo: ", error)

func _on_settings_button_pressed() -> void:
<<<<<<< HEAD
	$SettingsScreen.visible = true

func _on_credits_button_pressed() -> void:
	$CreditsScreen.visible = true

func _on_settings_back_button_pressed() -> void:
	$SettingsScreen.visible = false

func _on_credits_back_button_pressed() -> void:
	$CreditsScreen.visible = false
=======
	get_tree().change_scene_to_file("res://scenes/Settings_Screen.tscn")

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Credit_Screen.tscn")
>>>>>>> 45327c7 (update)
