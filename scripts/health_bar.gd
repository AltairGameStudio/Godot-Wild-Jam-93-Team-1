extends ProgressBar

var player: Node2D

func _ready() -> void:
	# Encontra o jogador
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	# Verifica se o jogador ainda existe na cena
	if is_instance_valid(player):
		# Sincroniza os valores da barra com os atributos reais do player
		max_value = player.max_health
		value = player.current_health
	else:
		# Se o jogador morreu, zera a barra
		value = 0
