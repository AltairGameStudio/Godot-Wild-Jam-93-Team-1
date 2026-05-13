extends Control

var dialog_box_visible: bool = false
var needs_interaction: bool = false
var dismiss_timer: Timer
var fade_out_tween: Tween

func _ready() -> void:
	dismiss_timer = Timer.new()
	add_child(dismiss_timer)
	dismiss_timer.timeout.connect(self.dismiss)

func display_text(text: String, stops_player: bool = false) -> void:
	if needs_interaction and not stops_player:
<<<<<<< HEAD
func display_text(text: String, pauses_game: bool = true) -> void:
	if needs_interaction and not pauses_game:
		return # Se já está esperando interação, não mostra outro texto
	$DialogLabel.text = text
	dialog_box_visible = true
	needs_interaction = pauses_game
	var fade_in_time = 0.3
	if fade_out_tween:
		fade_out_tween.kill()
	create_tween().tween_property(self, "modulate:a", 1.0, fade_in_time)
<<<<<<< HEAD
	if pauses_game:
		get_tree().paused = true
=======
	if stops_player:
		$/root/World/Player.process_mode = Node2D.PROCESS_MODE_DISABLED
>>>>>>> 45327c7 (update)
		dismiss_timer.stop() # Para o timer caso ele já estivesse contando
	else:
		var reading_time = max(2.0, text.length() * 0.025)
		var total_time = fade_in_time + reading_time
		dismiss_timer.start(total_time)

func _unhandled_input(event: InputEvent) -> void:
	if (
		needs_interaction and
		dialog_box_visible and (
			event is InputEventMouseButton or
			event.is_action_pressed("interact")
		)):
<<<<<<< HEAD
		get_viewport().set_input_as_handled()
		get_tree().paused = false
=======
		$/root/World/Player.process_mode = Node2D.PROCESS_MODE_INHERIT
>>>>>>> 45327c7 (update)
		dismiss()

func dismiss() -> void:
	dialog_box_visible = false
	needs_interaction = false
	fade_out_tween = create_tween()
	fade_out_tween.tween_property(self, "modulate:a", 0.0, 0.5)