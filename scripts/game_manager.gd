extends Node

# Tempo até o jogo acabar
var total_time: float = 120.0
var time_remaining: float
var is_game_over: bool = false

func _ready() -> void:
	time_remaining = total_time

func _process(delta: float) -> void:
	if is_game_over:
		return
		
	# Reduz o tempo frame a frame
	time_remaining -= delta
	
	if time_remaining <= 0.0:
		time_remaining = 0.0
		end_game("O seu tempo acabou.")

func end_game(reason: String) -> void:
	is_game_over = true
	print("GAME OVER: ", reason)
	
	get_tree().paused = true
