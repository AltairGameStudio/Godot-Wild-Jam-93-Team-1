extends AnimatedSprite2D

func _ready() -> void:
	# Começa invisível
	visible = false

func _on_timer_timeout() -> void:
	# Garante que o objeto está visível
	visible = true
	# Reseta a animação para o começo
	frame = 0
	# Toca a animação
	play("default")

func _on_animation_finished() -> void:
	# Esconde o objeto assim que a animação terminar
	visible = false
