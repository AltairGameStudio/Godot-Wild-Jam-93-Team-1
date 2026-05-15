extends Area2D

@export var speed: float = 1200.0
@export var damage: int = 1
@export var max_range: float = 800.0

var traveled_distance: float = 0.0

func _physics_process(delta: float) -> void:
	# Move a bala para frente
	var move_amount = speed * delta
	position += transform.x * move_amount
	traveled_distance += move_amount
	
	# Destrói a bala se ela for longe demais
	if traveled_distance >= max_range:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Ignora se a bala bater no próprio jogador
	if body.is_in_group("player"):
		return
		
	# Se acertou um inimigo, aplica o dano
	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()
