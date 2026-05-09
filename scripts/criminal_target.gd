extends Node2D

var health = 3

func take_damage(amount: int) -> void:
	health -= amount
	print("Criminoso levou tiro! Vida restante: ", health)
	
	if health <= 0:
		die()

func die() -> void:
	print("Criminoso eliminado!")
	# Remove o inimigo da cena
	queue_free()
