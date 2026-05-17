extends Control

func fade_in() -> void:
	modulate.a = 0.0
	visible = true
	MusicManager.play_exploration_music()
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
	GameManager.start_game()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
