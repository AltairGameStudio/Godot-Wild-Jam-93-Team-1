extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intro_sequence.tscn")

func _on_settings_button_pressed() -> void:
	$SettingsScreen.visible = true

func _on_credits_button_pressed() -> void:
	$CreditsScreen.visible = true

func _on_settings_back_button_pressed() -> void:
	$SettingsScreen.visible = false

func _on_credits_back_button_pressed() -> void:
	$CreditsScreen.visible = false
