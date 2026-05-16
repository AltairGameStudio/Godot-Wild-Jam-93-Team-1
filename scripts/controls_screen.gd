extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_controls"):
		# Impede de abrir o tutorial se o jogador já perdeu ou ganhou o jogo
		if GameManager.is_game_over:
			return
			
		toggle_controls()

func toggle_controls() -> void:
	visible = !visible
	# Pausa o jogo enquanto o tutorial estiver aberto
	get_tree().paused = visible
