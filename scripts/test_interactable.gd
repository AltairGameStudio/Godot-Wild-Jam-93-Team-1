extends StaticBody2D

#ID do item necessário para quebrar esse obstáculo
@export var required_item: String = "pliers"

# Interação para dar dicas ao jogador
func on_interact() -> void:
	print("Uma tela de arame resistente bloqueia o caminho. Preciso de algo para cortá-la.")

func on_item_used(used_item_id: String) -> bool:
	if used_item_id == required_item:
		print("Você usou o(a) ", used_item_id, " e abriu o caminho!")
		# Destrói a cerca de arame
		queue_free()
		# Retorna verdadeiro para que o inventário saiba que o item foi gasto
		return true
	else:
		print("Isso não parece funcionar aqui...")
		return false
