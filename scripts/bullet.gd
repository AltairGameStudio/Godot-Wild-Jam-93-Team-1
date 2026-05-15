extends Area2D

@export var speed: float = 1200.0
@export var damage: int = 1
@export var max_range: float = 800.0

var traveled_distance: float = 0.0

# Guarda quem atirou
var shooter: Node2D 

func _physics_process(delta: float) -> void:
	var move_amount = speed * delta
	position += transform.x * move_amount
	traveled_distance += move_amount
	
	if traveled_distance >= max_range:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Se a bala bater no próprio atirador, ela simplesmente ignora
	if body == shooter:
		return
		
	# Se bateu em qualquer outra coisa que toma dano...
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
	queue_free()
